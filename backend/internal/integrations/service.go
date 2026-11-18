package integrations

import (
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"html"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"

	"github.com/KidOBricks/tasker/backend/internal/crypto"
	"github.com/KidOBricks/tasker/backend/internal/llm"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
	"golang.org/x/oauth2/microsoft"
)

type Service struct {
	App        core.App
	PublicURL  string
	EncKey     []byte
	Extractor  llm.ExtractorProvider
	Endpoints  ProviderEndpoints
	HTTPClient *http.Client
	GoogleCfg  *oauth2.Config
	MsCfg      *oauth2.Config
}

type oauthStatePayload struct {
	UserID      string `json:"u"`
	Provider    string `json:"p"`
	RedirectURI string `json:"r,omitempty"`
	ExpiresAt   int64  `json:"e"`
}

func NewServiceFromEnv(app core.App) (*Service, error) {
	rawKey := strings.TrimSpace(os.Getenv("TOKEN_ENCRYPTION_KEY"))
	if rawKey == "" {
		// Deterministic dev fallback derived only if unset in non-production environments.
		rawKey = "tasker-dev-insecure-key-set-TOKEN_ENCRYPTION_KEY-in-prod"
	}
	encKey, err := crypto.ParseKey(rawKey)
	if err != nil {
		return nil, err
	}

	publicURL := strings.TrimRight(strings.TrimSpace(os.Getenv("TASKER_PUBLIC_URL")), "/")
	if publicURL == "" {
		publicURL = "http://127.0.0.1:8090"
	}

	httpClient := &http.Client{Timeout: 20 * time.Second}
	extractor := llm.NewExtractorFromConfig(llm.ConfigFromEnv(), httpClient)

	svc := &Service{
		App:        app,
		PublicURL:  publicURL,
		EncKey:     encKey,
		Extractor:  extractor,
		Endpoints:  DefaultEndpoints(),
		HTTPClient: httpClient,
	}

	if gid, gsec := strings.TrimSpace(os.Getenv("GOOGLE_CLIENT_ID")), strings.TrimSpace(os.Getenv("GOOGLE_CLIENT_SECRET")); gid != "" && gsec != "" {
		svc.GoogleCfg = &oauth2.Config{
			ClientID:     gid,
			ClientSecret: gsec,
			RedirectURL:  publicURL + "/api/integrations/google/callback",
			Scopes: []string{
				"openid",
				"email",
				"profile",
				"https://www.googleapis.com/auth/calendar.readonly",
				"https://www.googleapis.com/auth/gmail.readonly",
			},
			Endpoint: google.Endpoint,
		}
	}

	if mid, msec := strings.TrimSpace(os.Getenv("MICROSOFT_CLIENT_ID")), strings.TrimSpace(os.Getenv("MICROSOFT_CLIENT_SECRET")); mid != "" && msec != "" {
		svc.MsCfg = &oauth2.Config{
			ClientID:     mid,
			ClientSecret: msec,
			RedirectURL:  publicURL + "/api/integrations/microsoft/callback",
			Scopes: []string{
				"offline_access",
				"User.Read",
				"Calendars.Read",
			},
			Endpoint: microsoft.AzureADEndpoint("common"),
		}
	}

	return svc, nil
}

func (s *Service) RegisterRoutes(se *core.ServeEvent) {
	// Integrations health endpoint (PocketBase already reserves GET /api/health)
	se.Router.GET("/api/integrations/health", func(e *core.RequestEvent) error {
		return e.JSON(http.StatusOK, map[string]any{
			"status":     "ok",
			"publicUrl":  s.PublicURL,
			"google":     s.GoogleCfg != nil,
			"microsoft":  s.MsCfg != nil,
			"serverTime": time.Now().UTC().Format(time.RFC3339),
		})
	})

	// List connected providers for the signed-in user
	se.Router.GET("/api/integrations/status", s.handleStatus).Bind(apis.RequireAuth("users"))

	// Start OAuth2 integration flow (returns authUrl to open in browser)
	se.Router.POST("/api/integrations/{provider}/start", s.handleStartOAuth).Bind(apis.RequireAuth("users"))

	// OAuth2 callback from Google / Microsoft
	se.Router.GET("/api/integrations/{provider}/callback", s.handleOAuthCallback)

	// Disconnect provider
	se.Router.DELETE("/api/integrations/{provider}", s.handleDisconnect).Bind(apis.RequireAuth("users"))

	// Manual sync trigger for the signed-in user
	se.Router.POST("/api/integrations/sync", s.handleSyncNow).Bind(apis.RequireAuth("users"))
}

func (s *Service) RegisterCron() {
	s.App.Cron().MustAdd("sync_external_integrations", "*/15 * * * *", func() {
		ctx, cancel := context.WithTimeout(context.Background(), 2*time.Minute)
		defer cancel()
		s.SyncAllUsers(ctx)
	})
}

func (s *Service) handleStatus(e *core.RequestEvent) error {
	records, err := s.App.FindRecordsByFilter(
		"oauth_connections",
		"user = {:uid}",
		"",
		10,
		0,
		map[string]any{"uid": e.Auth.Id},
	)
	if err != nil {
		return e.InternalServerError("failed to query connections", err)
	}

	out := map[string]any{
		"google":    nil,
		"microsoft": nil,
		"configured": map[string]bool{
			"google":    s.GoogleCfg != nil,
			"microsoft": s.MsCfg != nil,
		},
	}

	for _, rec := range records {
		prov := rec.GetString("provider")
		out[prov] = map[string]any{
			"provider":     prov,
			"email":        rec.GetString("accountEmail"),
			"displayName":  rec.GetString("displayName"),
			"isConnected":  true,
			"lastSyncedAt": rec.GetString("lastSyncedAt"),
		}
	}
	return e.JSON(http.StatusOK, out)
}

func (s *Service) handleStartOAuth(e *core.RequestEvent) error {
	provider := strings.ToLower(e.Request.PathValue("provider"))
	cfg := s.providerOAuthConfig(provider)
	if cfg == nil {
		return e.BadRequestError(fmt.Sprintf("%s OAuth credentials are not configured on the server.", provider), nil)
	}

	var body struct {
		RedirectURI string `json:"redirectUri"`
	}
	_ = e.BindBody(&body)

	state, err := s.SignState(oauthStatePayload{
		UserID:      e.Auth.Id,
		Provider:    provider,
		RedirectURI: sanitizeClientRedirect(body.RedirectURI, s.PublicURL),
		ExpiresAt:   time.Now().Add(10 * time.Minute).Unix(),
	})
	if err != nil {
		return e.InternalServerError("failed to sign oauth state", err)
	}

	opts := []oauth2.AuthCodeOption{oauth2.AccessTypeOffline}
	if provider == "google" {
		opts = append(opts, oauth2.SetAuthURLParam("prompt", "consent"))
	}
	authURL := cfg.AuthCodeURL(state, opts...)

	return e.JSON(http.StatusOK, map[string]string{
		"authUrl": authURL,
	})
}

func (s *Service) handleOAuthCallback(e *core.RequestEvent) error {
	provider := strings.ToLower(e.Request.PathValue("provider"))
	cfg := s.providerOAuthConfig(provider)
	if cfg == nil {
		return e.BadRequestError("provider not configured", nil)
	}

	if errMsg := e.Request.URL.Query().Get("error"); errMsg != "" {
		return e.HTML(http.StatusBadRequest, renderCallbackHTML(false, "Authorization cancelled: "+errMsg, ""))
	}

	stateToken := e.Request.URL.Query().Get("state")
	code := e.Request.URL.Query().Get("code")
	payload, err := s.VerifyState(stateToken)
	if err != nil || payload.Provider != provider {
		return e.HTML(http.StatusBadRequest, renderCallbackHTML(false, "Invalid or expired OAuth state.", ""))
	}

	ctx := context.WithValue(e.Request.Context(), oauth2.HTTPClient, s.HTTPClient)
	token, err := cfg.Exchange(ctx, code)
	if err != nil {
		return e.HTML(http.StatusBadGateway, renderCallbackHTML(false, "Failed to exchange OAuth code.", ""))
	}

	var email, displayName string
	switch provider {
	case "google":
		email, displayName, err = FetchGoogleUserEmail(ctx, s.HTTPClient, s.Endpoints.GoogleAPIBase, token.AccessToken)
	case "microsoft":
		email, displayName, err = FetchMicrosoftUserProfile(ctx, s.HTTPClient, s.Endpoints.MicrosoftAPIBase, token.AccessToken)
	}
	if err != nil {
		email = ""
	}

	if err := s.saveConnectionTokens(payload.UserID, provider, email, displayName, token, strings.Join(cfg.Scopes, " ")); err != nil {
		return e.HTML(http.StatusInternalServerError, renderCallbackHTML(false, "Failed to persist connection.", ""))
	}

	// Perform initial sync immediately so events & email suggestions appear right away
	_, _ = s.SyncUser(ctx, payload.UserID)

	if payload.RedirectURI != "" {
		sep := "?"
		if strings.Contains(payload.RedirectURI, "?") {
			sep = "&"
		}
		target := payload.RedirectURI + sep + "connected=" + url.QueryEscape(provider)
		return e.Redirect(http.StatusFound, target)
	}

	return e.HTML(http.StatusOK, renderCallbackHTML(true, fmt.Sprintf("Connected %s (%s). You can return to Tasker.", provider, email), s.PublicURL))
}

func (s *Service) handleDisconnect(e *core.RequestEvent) error {
	provider := strings.ToLower(e.Request.PathValue("provider"))
	records, err := s.App.FindRecordsByFilter(
		"oauth_connections",
		"user = {:uid} && provider = {:prov}",
		"",
		1,
		0,
		map[string]any{"uid": e.Auth.Id, "prov": provider},
	)
	if err != nil {
		return e.InternalServerError("query failed", err)
	}
	for _, rec := range records {
		if err := s.App.Delete(rec); err != nil {
			return e.InternalServerError("delete failed", err)
		}
	}
	return e.JSON(http.StatusOK, map[string]bool{"disconnected": true})
}

func (s *Service) handleSyncNow(e *core.RequestEvent) error {
	stats, err := s.SyncUser(e.Request.Context(), e.Auth.Id)
	if err != nil {
		return e.InternalServerError("sync failed", err)
	}
	return e.JSON(http.StatusOK, stats)
}

type SyncStats struct {
	EventsSynced      int      `json:"eventsSynced"`
	SuggestionsSynced int      `json:"suggestionsSynced"`
	Errors            []string `json:"errors,omitempty"`
}

func (s *Service) SyncAllUsers(ctx context.Context) {
	records, err := s.App.FindRecordsByFilter("oauth_connections", "id != ''", "", 500, 0)
	if err != nil {
		return
	}
	seen := map[string]bool{}
	for _, rec := range records {
		uid := rec.GetString("user")
		if uid == "" || seen[uid] {
			continue
		}
		seen[uid] = true
		_, _ = s.SyncUser(ctx, uid)
	}
}

func (s *Service) SyncUser(ctx context.Context, userID string) (SyncStats, error) {
	stats := SyncStats{}
	conns, err := s.App.FindRecordsByFilter(
		"oauth_connections",
		"user = {:uid}",
		"",
		10,
		0,
		map[string]any{"uid": userID},
	)
	if err != nil {
		return stats, err
	}

	now := time.Now().UTC()
	for _, conn := range conns {
		prov := conn.GetString("provider")
		accessToken, err := s.ensureFreshAccessToken(ctx, conn)
		if err != nil {
			stats.Errors = append(stats.Errors, fmt.Sprintf("%s auth: %v", prov, err))
			continue
		}

		switch prov {
		case "google":
			events, err := FetchGoogleCalendarEvents(ctx, s.HTTPClient, s.Endpoints.GoogleAPIBase, accessToken, now)
			if err != nil {
				stats.Errors = append(stats.Errors, fmt.Sprintf("google calendar: %v", err))
			} else {
				stats.EventsSynced += s.upsertExternalEvents(userID, events)
			}

			emails, err := FetchGmailUnreadMessages(ctx, s.HTTPClient, s.Endpoints.GoogleAPIBase, accessToken)
			if err != nil {
				stats.Errors = append(stats.Errors, fmt.Sprintf("gmail: %v", err))
			} else {
				stats.SuggestionsSynced += s.upsertSuggestionsFromEmails(ctx, userID, emails, now)
			}
		case "microsoft":
			events, err := FetchMicrosoftCalendarEvents(ctx, s.HTTPClient, s.Endpoints.MicrosoftAPIBase, accessToken, now)
			if err != nil {
				stats.Errors = append(stats.Errors, fmt.Sprintf("outlook calendar: %v", err))
			} else {
				stats.EventsSynced += s.upsertExternalEvents(userID, events)
			}
		}

		conn.Set("lastSyncedAt", now.Format(time.RFC3339))
		_ = s.App.Save(conn)
	}
	return stats, nil
}

func (s *Service) ensureFreshAccessToken(ctx context.Context, conn *core.Record) (string, error) {
	accessToken, err := crypto.Decrypt(conn.GetString("encryptedAccessToken"), s.EncKey)
	if err != nil {
		return "", err
	}
	refreshToken, _ := crypto.Decrypt(conn.GetString("encryptedRefreshToken"), s.EncKey)
	expiresAt, _ := time.Parse(time.RFC3339, conn.GetString("expiresAt"))

	if accessToken != "" && (expiresAt.IsZero() || time.Until(expiresAt) > 2*time.Minute) {
		return accessToken, nil
	}

	cfg := s.providerOAuthConfig(conn.GetString("provider"))
	if cfg == nil || refreshToken == "" {
		if accessToken != "" {
			return accessToken, nil
		}
		return "", errors.New("missing refresh token or provider config")
	}

	oauthCtx := context.WithValue(ctx, oauth2.HTTPClient, s.HTTPClient)
	ts := cfg.TokenSource(oauthCtx, &oauth2.Token{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		Expiry:       time.Now().Add(-time.Minute),
	})
	fresh, err := ts.Token()
	if err != nil {
		return "", err
	}

	_ = s.saveConnectionTokens(
		conn.GetString("user"),
		conn.GetString("provider"),
		conn.GetString("accountEmail"),
		conn.GetString("displayName"),
		fresh,
		conn.GetString("scopes"),
	)
	return fresh.AccessToken, nil
}

func (s *Service) saveConnectionTokens(userID, provider, email, displayName string, tok *oauth2.Token, scopes string) error {
	col, err := s.App.FindCollectionByNameOrId("oauth_connections")
	if err != nil {
		return err
	}

	existing, _ := s.App.FindFirstRecordByFilter(
		"oauth_connections",
		"user = {:uid} && provider = {:prov}",
		map[string]any{"uid": userID, "prov": provider},
	)
	rec := existing
	if rec == nil {
		rec = core.NewRecord(col)
		rec.Set("user", userID)
		rec.Set("provider", provider)
	}

	encAccess, err := crypto.Encrypt(tok.AccessToken, s.EncKey)
	if err != nil {
		return err
	}
	rec.Set("encryptedAccessToken", encAccess)

	if tok.RefreshToken != "" {
		encRefresh, err := crypto.Encrypt(tok.RefreshToken, s.EncKey)
		if err != nil {
			return err
		}
		rec.Set("encryptedRefreshToken", encRefresh)
	}
	if email != "" {
		rec.Set("accountEmail", email)
	}
	if displayName != "" {
		rec.Set("displayName", displayName)
	}
	if !tok.Expiry.IsZero() {
		rec.Set("expiresAt", tok.Expiry.UTC().Format(time.RFC3339))
	}
	if scopes != "" {
		rec.Set("scopes", scopes)
	}
	return s.App.Save(rec)
}

func (s *Service) upsertExternalEvents(userID string, events []CalendarEventDTO) int {
	col, err := s.App.FindCollectionByNameOrId("external_events")
	if err != nil {
		return 0
	}
	count := 0
	for _, ev := range events {
		rec, _ := s.App.FindFirstRecordByFilter(
			"external_events",
			"user = {:uid} && source = {:src} && externalId = {:eid}",
			map[string]any{"uid": userID, "src": ev.Source, "eid": ev.ExternalID},
		)
		if rec == nil {
			rec = core.NewRecord(col)
			rec.Set("user", userID)
			rec.Set("source", ev.Source)
			rec.Set("externalId", ev.ExternalID)
			rec.Set("hasLinkedTask", false)
		}
		rec.Set("title", ev.Title)
		rec.Set("startTime", ev.StartTime.UTC().Format(time.RFC3339))
		rec.Set("endTime", ev.EndTime.UTC().Format(time.RFC3339))
		rec.Set("location", ev.Location)
		rec.Set("description", ev.Description)
		rec.Set("meetingUrl", ev.MeetingURL)
		rec.Set("attendees", ev.Attendees)
		rec.Set("deletedAt", "")
		if err := s.App.Save(rec); err == nil {
			count++
		}
	}
	return count
}

func (s *Service) upsertSuggestionsFromEmails(ctx context.Context, userID string, emails []EmailMessageDTO, now time.Time) int {
	col, err := s.App.FindCollectionByNameOrId("task_suggestions")
	if err != nil {
		return 0
	}
	count := 0
	for _, em := range emails {
		existing, _ := s.App.FindFirstRecordByFilter(
			"task_suggestions",
			"user = {:uid} && emailId = {:eid}",
			map[string]any{"uid": userID, "eid": em.EmailID},
		)
		if existing != nil {
			// Skip already-extracted emails so dismissed/accepted items stay dismissed/accepted
			continue
		}

		extracted, err := s.Extractor.Extract(ctx, llm.EmailInput{
			ID:      em.EmailID,
			Sender:  em.Sender,
			Subject: em.Subject,
			Snippet: em.Snippet,
		})
		if err != nil {
			continue
		}

		rec := core.NewRecord(col)
		rec.Set("user", userID)
		rec.Set("emailId", em.EmailID)
		rec.Set("sender", em.Sender)
		rec.Set("subject", em.Subject)
		rec.Set("snippet", em.Snippet)
		rec.Set("receivedAt", em.ReceivedAt.UTC().Format(time.RFC3339))
		rec.Set("title", extracted.Title)
		rec.Set("description", extracted.Description)
		rec.Set("categoryId", extracted.CategoryID)
		rec.Set("importance", extracted.Importance)
		if extracted.DaysUntilDue != nil {
			rec.Set("suggestedDueDate", now.Add(time.Duration(*extracted.DaysUntilDue)*24*time.Hour).Format(time.RFC3339))
		}
		rec.Set("status", "pending")
		if err := s.App.Save(rec); err == nil {
			count++
		}
	}
	return count
}

func (s *Service) providerOAuthConfig(provider string) *oauth2.Config {
	switch provider {
	case "google":
		return s.GoogleCfg
	case "microsoft":
		return s.MsCfg
	default:
		return nil
	}
}

func (s *Service) SignState(p oauthStatePayload) (string, error) {
	raw, err := json.Marshal(p)
	if err != nil {
		return "", err
	}
	data := base64.RawURLEncoding.EncodeToString(raw)
	mac := hmac.New(sha256.New, s.EncKey)
	_, _ = mac.Write([]byte(data))
	sig := base64.RawURLEncoding.EncodeToString(mac.Sum(nil))
	return data + "." + sig, nil
}

func (s *Service) VerifyState(token string) (oauthStatePayload, error) {
	parts := strings.Split(token, ".")
	if len(parts) != 2 {
		return oauthStatePayload{}, errors.New("malformed state")
	}
	mac := hmac.New(sha256.New, s.EncKey)
	_, _ = mac.Write([]byte(parts[0]))
	expectedSig := base64.RawURLEncoding.EncodeToString(mac.Sum(nil))
	if !hmac.Equal([]byte(parts[1]), []byte(expectedSig)) {
		return oauthStatePayload{}, errors.New("invalid state signature")
	}
	raw, err := base64.RawURLEncoding.DecodeString(parts[0])
	if err != nil {
		return oauthStatePayload{}, err
	}
	var p oauthStatePayload
	if err := json.Unmarshal(raw, &p); err != nil {
		return oauthStatePayload{}, err
	}
	if time.Now().Unix() > p.ExpiresAt {
		return oauthStatePayload{}, errors.New("expired state")
	}
	return p, nil
}

func sanitizeClientRedirect(raw, publicURL string) string {
	trimmed := strings.TrimSpace(raw)
	if trimmed == "" {
		return ""
	}
	u, err := url.Parse(trimmed)
	if err != nil {
		return ""
	}
	if u.Scheme == "tasker" {
		return trimmed
	}
	if (u.Scheme == "http" || u.Scheme == "https") && (strings.HasPrefix(trimmed, publicURL) || u.Hostname() == "localhost" || u.Hostname() == "127.0.0.1") {
		return trimmed
	}
	return ""
}

func renderCallbackHTML(success bool, message, backURL string) string {
	color := "#10B981"
	title := "Connected"
	if !success {
		color = "#EF4444"
		title = "Connection Failed"
	}
	link := ""
	if backURL != "" {
		link = fmt.Sprintf(`<p style="margin-top:20px;"><a href="%s" style="color:#818CF8;">Return to Tasker</a></p>`, html.EscapeString(backURL))
	}
	return fmt.Sprintf(`<!doctype html>
<html><body style="font-family:system-ui,sans-serif;background:#0F172A;color:#F8FAFC;display:flex;align-items:center;justify-content:center;min-height:100vh;margin:0;">
  <div style="background:#1E293B;padding:32px;border-radius:16px;max-width:420px;text-align:center;border:1px solid #334155;">
    <h2 style="color:%s;margin-top:0;">%s</h2>
    <p style="color:#CBD5E1;">%s</p>
    %s
  </div>
</body></html>`, color, title, html.EscapeString(message), link)
}
