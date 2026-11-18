package integrations

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/KidOBricks/tasker/backend/internal/crypto"
	"github.com/KidOBricks/tasker/backend/internal/llm"
	"github.com/KidOBricks/tasker/backend/internal/schema"
	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/tests"
	"golang.org/x/oauth2"
)

func TestSchemaAndSyncUserEndToEnd(t *testing.T) {
	app, err := tests.NewTestApp()
	if err != nil {
		t.Fatalf("NewTestApp failed: %v", err)
	}
	defer app.Cleanup()

	if err := schema.EnsureSchema(app); err != nil {
		t.Fatalf("EnsureSchema failed: %v", err)
	}

	// Create invited user
	usersCol, err := app.FindCollectionByNameOrId("users")
	if err != nil {
		t.Fatal(err)
	}
	user := core.NewRecord(usersCol)
	user.SetEmail("alice@example.com")
	user.SetPassword("StrongPass123!")
	user.Set("displayName", "Alice")
	user.Set("role", "user")
	user.Set("suspended", false)
	if err := app.Save(user); err != nil {
		t.Fatalf("failed to create user: %v", err)
	}

	// Mock Google & Microsoft APIs
	mockServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch {
		case strings.HasPrefix(r.URL.Path, "/calendar/v3/calendars/primary/events"):
			_ = json.NewEncoder(w).Encode(map[string]any{
				"items": []map[string]any{
					{
						"id":          "g_ev_1",
						"summary":     "Architecture Sync",
						"hangoutLink": "https://meet.google.com/abc-xyz",
						"start":       map[string]string{"dateTime": time.Now().Add(3 * time.Hour).UTC().Format(time.RFC3339)},
						"end":         map[string]string{"dateTime": time.Now().Add(4 * time.Hour).UTC().Format(time.RFC3339)},
					},
				},
			})
		case strings.HasPrefix(r.URL.Path, "/gmail/v1/users/me/messages/msg_99"):
			_ = json.NewEncoder(w).Encode(map[string]any{
				"snippet": "Your cloud invoice #99 is due tomorrow.",
				"payload": map[string]any{
					"headers": []map[string]string{
						{"name": "From", "value": "billing@vendor.io"},
						{"name": "Subject", "value": "Invoice #99 Due Tomorrow"},
					},
				},
			})
		case strings.HasPrefix(r.URL.Path, "/gmail/v1/users/me/messages"):
			_ = json.NewEncoder(w).Encode(map[string]any{
				"messages": []map[string]string{{"id": "msg_99"}},
			})
		case strings.HasPrefix(r.URL.Path, "/v1.0/me/events"):
			_ = json.NewEncoder(w).Encode(map[string]any{
				"value": []map[string]any{
					{
						"id":          "ms_ev_1",
						"subject":     "Quarterly Planning",
						"bodyPreview": "Review roadmap",
						"start":       map[string]string{"dateTime": time.Now().Add(6 * time.Hour).UTC().Format(time.RFC3339)},
						"end":         map[string]string{"dateTime": time.Now().Add(7 * time.Hour).UTC().Format(time.RFC3339)},
						"location":    map[string]string{"displayName": "Teams"},
					},
				},
			})
		default:
			http.NotFound(w, r)
		}
	}))
	defer mockServer.Close()

	key, _ := crypto.ParseKey("0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef")
	svc := &Service{
		App:       app,
		PublicURL: "https://1-2-3-4.sslip.io",
		EncKey:    key,
		Extractor: &llm.HeuristicExtractor{},
		Endpoints: ProviderEndpoints{
			GoogleAPIBase:    mockServer.URL,
			MicrosoftAPIBase: mockServer.URL,
		},
		HTTPClient: mockServer.Client(),
	}

	// Save encrypted connections
	tok := &oauth2.Token{
		AccessToken:  "access-123",
		RefreshToken: "refresh-456",
		Expiry:       time.Now().Add(time.Hour),
	}
	if err := svc.saveConnectionTokens(user.Id, "google", "alice@gmail.com", "Alice", tok, "calendar.readonly gmail.readonly"); err != nil {
		t.Fatalf("save google conn failed: %v", err)
	}
	if err := svc.saveConnectionTokens(user.Id, "microsoft", "alice@outlook.com", "Alice", tok, "Calendars.Read"); err != nil {
		t.Fatalf("save ms conn failed: %v", err)
	}

	stats, err := svc.SyncUser(context.Background(), user.Id)
	if err != nil {
		t.Fatalf("SyncUser failed: %v", err)
	}
	if stats.EventsSynced != 2 || stats.SuggestionsSynced != 1 {
		t.Fatalf("unexpected sync stats: %+v", stats)
	}

	// Re-running sync should not duplicate the already-extracted email suggestion
	stats2, err := svc.SyncUser(context.Background(), user.Id)
	if err != nil {
		t.Fatalf("second SyncUser failed: %v", err)
	}
	if stats2.SuggestionsSynced != 0 {
		t.Fatalf("expected 0 new suggestions on duplicate email, got %d", stats2.SuggestionsSynced)
	}
}

func TestSignVerifyStateAndRedirectSanitizer(t *testing.T) {
	key, _ := crypto.ParseKey("test-signing-key-value")
	svc := &Service{EncKey: key}

	tok, err := svc.SignState(oauthStatePayload{
		UserID:      "u1",
		Provider:    "google",
		RedirectURI: "tasker://oauth-callback",
		ExpiresAt:   time.Now().Add(5 * time.Minute).Unix(),
	})
	if err != nil {
		t.Fatal(err)
	}
	parsed, err := svc.VerifyState(tok)
	if err != nil {
		t.Fatalf("VerifyState failed: %v", err)
	}
	if parsed.UserID != "u1" || parsed.Provider != "google" {
		t.Fatalf("unexpected payload: %+v", parsed)
	}

	if got := sanitizeClientRedirect("https://evil.com/steal", "https://1-2-3-4.sslip.io"); got != "" {
		t.Fatalf("expected untrusted redirect to be rejected, got %q", got)
	}
	if got := sanitizeClientRedirect("tasker://oauth-callback", "https://1-2-3-4.sslip.io"); got != "tasker://oauth-callback" {
		t.Fatalf("expected app deep link to be allowed, got %q", got)
	}
}

func TestRegisterRoutesDoesNotConflictWithHealth(t *testing.T) {
	app, err := tests.NewTestApp()
	if err != nil {
		t.Fatalf("NewTestApp failed: %v", err)
	}
	defer app.Cleanup()

	svc := &Service{App: app, PublicURL: "https://1-2-3-4.sslip.io"}
	scenario := tests.ApiScenario{
		Name:   "integrations health endpoint",
		Method: http.MethodGet,
		URL:    "/api/integrations/health",
		BeforeTestFunc: func(t testing.TB, app *tests.TestApp, e *core.ServeEvent) {
			svc.RegisterRoutes(e)
		},
		ExpectedStatus:  http.StatusOK,
		ExpectedContent: []string{`"status":"ok"`, `"publicUrl":"https://1-2-3-4.sslip.io"`},
	}
	scenario.Test(t)
}
