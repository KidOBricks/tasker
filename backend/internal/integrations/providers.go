package integrations

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"
)

type CalendarEventDTO struct {
	ExternalID  string
	Source      string
	Title       string
	StartTime   time.Time
	EndTime     time.Time
	Location    string
	Description string
	MeetingURL  string
	Attendees   []string
}

type EmailMessageDTO struct {
	EmailID    string
	Sender     string
	Subject    string
	Snippet    string
	ReceivedAt time.Time
}

type ProviderEndpoints struct {
	GoogleAPIBase    string
	MicrosoftAPIBase string
}

func DefaultEndpoints() ProviderEndpoints {
	return ProviderEndpoints{
		GoogleAPIBase:    "https://www.googleapis.com",
		MicrosoftAPIBase: "https://graph.microsoft.com",
	}
}

func FetchGoogleUserEmail(ctx context.Context, client *http.Client, baseURL, accessToken string) (string, string, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, baseURL+"/oauth2/v2/userinfo", nil)
	if err != nil {
		return "", "", err
	}
	req.Header.Set("Authorization", "Bearer "+accessToken)
	resp, err := client.Do(req)
	if err != nil {
		return "", "", err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return "", "", fmt.Errorf("google userinfo status %d", resp.StatusCode)
	}
	var data struct {
		Email string `json:"email"`
		Name  string `json:"name"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
		return "", "", err
	}
	return data.Email, data.Name, nil
}

func FetchGoogleCalendarEvents(ctx context.Context, client *http.Client, baseURL, accessToken string, now time.Time) ([]CalendarEventDTO, error) {
	timeMin := url.QueryEscape(now.UTC().Add(-24 * time.Hour).Format(time.RFC3339))
	endpoint := fmt.Sprintf("%s/calendar/v3/calendars/primary/events?timeMin=%s&singleEvents=true&orderBy=startTime&maxResults=25", baseURL, timeMin)

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, endpoint, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", "Bearer "+accessToken)

	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(io.LimitReader(resp.Body, 2<<20))
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("google calendar status %d: %s", resp.StatusCode, string(body))
	}

	var parsed struct {
		Items []struct {
			ID          string `json:"id"`
			Summary     string `json:"summary"`
			Location    string `json:"location"`
			Description string `json:"description"`
			HangoutLink string `json:"hangoutLink"`
			Start       struct {
				DateTime string `json:"dateTime"`
				Date     string `json:"date"`
			} `json:"start"`
			End struct {
				DateTime string `json:"dateTime"`
				Date     string `json:"date"`
			} `json:"end"`
			Attendees []struct {
				Email string `json:"email"`
			} `json:"attendees"`
		} `json:"items"`
	}
	if err := json.Unmarshal(body, &parsed); err != nil {
		return nil, err
	}

	events := make([]CalendarEventDTO, 0, len(parsed.Items))
	for _, item := range parsed.Items {
		start := parseFlexibleTime(item.Start.DateTime, item.Start.Date, now.Add(2*time.Hour))
		end := parseFlexibleTime(item.End.DateTime, item.End.Date, start.Add(time.Hour))
		attendees := make([]string, 0, len(item.Attendees))
		for _, a := range item.Attendees {
			if a.Email != "" {
				attendees = append(attendees, a.Email)
			}
		}
		title := strings.TrimSpace(item.Summary)
		if title == "" {
			title = "Untitled Event"
		}
		loc := strings.TrimSpace(item.Location)
		if loc == "" && item.HangoutLink != "" {
			loc = "Google Meet"
		}
		events = append(events, CalendarEventDTO{
			ExternalID:  item.ID,
			Source:      "google",
			Title:       title,
			StartTime:   start,
			EndTime:     end,
			Location:    loc,
			Description: item.Description,
			MeetingURL:  item.HangoutLink,
			Attendees:   attendees,
		})
	}
	return events, nil
}

func FetchGmailUnreadMessages(ctx context.Context, client *http.Client, baseURL, accessToken string) ([]EmailMessageDTO, error) {
	listURL := fmt.Sprintf("%s/gmail/v1/users/me/messages?maxResults=10&q=%s", baseURL, url.QueryEscape("is:unread"))
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, listURL, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", "Bearer "+accessToken)

	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(io.LimitReader(resp.Body, 1<<20))
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("gmail list status %d: %s", resp.StatusCode, string(body))
	}

	var listData struct {
		Messages []struct {
			ID string `json:"id"`
		} `json:"messages"`
	}
	if err := json.Unmarshal(body, &listData); err != nil {
		return nil, err
	}

	results := make([]EmailMessageDTO, 0, len(listData.Messages))
	for i, m := range listData.Messages {
		if i >= 8 {
			break
		}
		msgURL := fmt.Sprintf("%s/gmail/v1/users/me/messages/%s?format=metadata&metadataHeaders=From&metadataHeaders=Subject&metadataHeaders=Date", baseURL, url.PathEscape(m.ID))
		mReq, err := http.NewRequestWithContext(ctx, http.MethodGet, msgURL, nil)
		if err != nil {
			continue
		}
		mReq.Header.Set("Authorization", "Bearer "+accessToken)
		mResp, err := client.Do(mReq)
		if err != nil {
			continue
		}
		mBody, _ := io.ReadAll(io.LimitReader(mResp.Body, 512*1024))
		mResp.Body.Close()
		if mResp.StatusCode != http.StatusOK {
			continue
		}

		var msgData struct {
			Snippet string `json:"snippet"`
			Payload struct {
				Headers []struct {
					Name  string `json:"name"`
					Value string `json:"value"`
				} `json:"headers"`
			} `json:"payload"`
		}
		if err := json.Unmarshal(mBody, &msgData); err != nil {
			continue
		}

		sender := "Unknown Sender"
		subject := "No Subject"
		receivedAt := time.Now().UTC()
		for _, h := range msgData.Payload.Headers {
			switch strings.ToLower(h.Name) {
			case "from":
				sender = h.Value
			case "subject":
				subject = h.Value
			case "date":
				if parsed, err := parseEmailDate(h.Value); err == nil {
					receivedAt = parsed
				}
			}
		}

		results = append(results, EmailMessageDTO{
			EmailID:    m.ID,
			Sender:     sender,
			Subject:    subject,
			Snippet:    msgData.Snippet,
			ReceivedAt: receivedAt,
		})
	}
	return results, nil
}

func FetchMicrosoftUserProfile(ctx context.Context, client *http.Client, baseURL, accessToken string) (string, string, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, baseURL+"/v1.0/me", nil)
	if err != nil {
		return "", "", err
	}
	req.Header.Set("Authorization", "Bearer "+accessToken)
	resp, err := client.Do(req)
	if err != nil {
		return "", "", err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return "", "", fmt.Errorf("microsoft graph /me status %d", resp.StatusCode)
	}
	var data struct {
		Mail              string `json:"mail"`
		UserPrincipalName string `json:"userPrincipalName"`
		DisplayName       string `json:"displayName"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
		return "", "", err
	}
	email := data.Mail
	if email == "" {
		email = data.UserPrincipalName
	}
	return email, data.DisplayName, nil
}

func FetchMicrosoftCalendarEvents(ctx context.Context, client *http.Client, baseURL, accessToken string, now time.Time) ([]CalendarEventDTO, error) {
	endpoint := baseURL + "/v1.0/me/events?$select=id,subject,start,end,location,bodyPreview,onlineMeeting,attendees&$orderby=start/dateTime&$top=25"
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, endpoint, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", "Bearer "+accessToken)
	req.Header.Set("Prefer", `outlook.timezone="UTC"`)

	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(io.LimitReader(resp.Body, 2<<20))
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("microsoft graph events status %d: %s", resp.StatusCode, string(body))
	}

	var parsed struct {
		Value []struct {
			ID          string `json:"id"`
			Subject     string `json:"subject"`
			BodyPreview string `json:"bodyPreview"`
			Start       struct {
				DateTime string `json:"dateTime"`
			} `json:"start"`
			End struct {
				DateTime string `json:"dateTime"`
			} `json:"end"`
			Location struct {
				DisplayName string `json:"displayName"`
			} `json:"location"`
			OnlineMeeting struct {
				JoinURL string `json:"joinUrl"`
			} `json:"onlineMeeting"`
			Attendees []struct {
				EmailAddress struct {
					Address string `json:"address"`
				} `json:"emailAddress"`
			} `json:"attendees"`
		} `json:"value"`
	}
	if err := json.Unmarshal(body, &parsed); err != nil {
		return nil, err
	}

	events := make([]CalendarEventDTO, 0, len(parsed.Value))
	for _, item := range parsed.Value {
		start := parseGraphTime(item.Start.DateTime, now.Add(2*time.Hour))
		end := parseGraphTime(item.End.DateTime, start.Add(time.Hour))
		attendees := make([]string, 0, len(item.Attendees))
		for _, a := range item.Attendees {
			if a.EmailAddress.Address != "" {
				attendees = append(attendees, a.EmailAddress.Address)
			}
		}
		title := strings.TrimSpace(item.Subject)
		if title == "" {
			title = "Untitled Meeting"
		}
		loc := strings.TrimSpace(item.Location.DisplayName)
		if loc == "" && item.OnlineMeeting.JoinURL != "" {
			loc = "Microsoft Teams"
		}
		events = append(events, CalendarEventDTO{
			ExternalID:  item.ID,
			Source:      "outlook",
			Title:       title,
			StartTime:   start,
			EndTime:     end,
			Location:    loc,
			Description: item.BodyPreview,
			MeetingURL:  item.OnlineMeeting.JoinURL,
			Attendees:   attendees,
		})
	}
	return events, nil
}

func parseFlexibleTime(dateTimeStr, dateStr string, fallback time.Time) time.Time {
	if dateTimeStr != "" {
		if t, err := time.Parse(time.RFC3339, dateTimeStr); err == nil {
			return t.UTC()
		}
	}
	if dateStr != "" {
		if t, err := time.Parse("2006-01-02", dateStr); err == nil {
			return t.UTC()
		}
	}
	return fallback.UTC()
}

func parseGraphTime(raw string, fallback time.Time) time.Time {
	if raw == "" {
		return fallback.UTC()
	}
	for _, layout := range []string{
		time.RFC3339,
		time.RFC3339Nano,
		"2006-01-02T15:04:05.9999999",
		"2006-01-02T15:04:05",
	} {
		if t, err := time.Parse(layout, raw); err == nil {
			return t.UTC()
		}
	}
	return fallback.UTC()
}

func parseEmailDate(raw string) (time.Time, error) {
	for _, layout := range []string{
		time.RFC1123Z,
		time.RFC1123,
		time.RFC822Z,
		time.RFC822,
		"Mon, 2 Jan 2006 15:04:05 -0700 (MST)",
	} {
		if t, err := time.Parse(layout, strings.TrimSpace(raw)); err == nil {
			return t.UTC(), nil
		}
	}
	return time.Time{}, fmt.Errorf("unrecognized date %q", raw)
}
