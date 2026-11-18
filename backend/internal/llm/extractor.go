package llm

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"time"
)

type EmailInput struct {
	ID      string
	Sender  string
	Subject string
	Snippet string
}

type Suggestion struct {
	Title        string `json:"title"`
	Description  string `json:"description"`
	CategoryID   string `json:"categoryId"`
	Importance   int    `json:"importance"`
	DaysUntilDue *int   `json:"daysUntilDue"`
}

type ExtractorProvider interface {
	Extract(ctx context.Context, email EmailInput) (Suggestion, error)
}

type Config struct {
	Provider string
	APIKey   string
	BaseURL  string
	Model    string
}

func ConfigFromEnv() Config {
	return Config{
		Provider: strings.ToLower(strings.TrimSpace(os.Getenv("LLM_PROVIDER"))),
		APIKey:   strings.TrimSpace(os.Getenv("LLM_API_KEY")),
		BaseURL:  strings.TrimRight(strings.TrimSpace(os.Getenv("LLM_BASE_URL")), "/"),
		Model:    strings.TrimSpace(os.Getenv("LLM_MODEL")),
	}
}

func NewExtractorFromConfig(cfg Config, client *http.Client) ExtractorProvider {
	if client == nil {
		client = &http.Client{Timeout: 15 * time.Second}
	}
	heuristic := &HeuristicExtractor{}

	if cfg.APIKey == "" && cfg.Provider != "openai_compat" {
		return heuristic
	}

	var primary ExtractorProvider
	switch cfg.Provider {
	case "gemini", "":
		if cfg.APIKey == "" {
			return heuristic
		}
		model := cfg.Model
		if model == "" {
			model = "gemini-3.5-flash-lite"
		}
		baseURL := cfg.BaseURL
		if baseURL == "" {
			baseURL = "https://generativelanguage.googleapis.com"
		}
		primary = &GeminiExtractor{
			APIKey:  cfg.APIKey,
			BaseURL: baseURL,
			Model:   model,
			Client:  client,
		}
	case "openai_compat", "openai", "groq", "openrouter":
		if cfg.BaseURL == "" {
			switch cfg.Provider {
			case "groq":
				cfg.BaseURL = "https://api.groq.com/openai/v1"
			case "openrouter":
				cfg.BaseURL = "https://openrouter.ai/api/v1"
			default:
				cfg.BaseURL = "https://api.openai.com/v1"
			}
		}
		if cfg.Model == "" {
			switch cfg.Provider {
			case "groq":
				cfg.Model = "llama-3.1-8b-instant"
			case "openrouter":
				cfg.Model = "meta-llama/llama-3.1-8b-instruct:free"
			default:
				cfg.Model = "gpt-4o-mini"
			}
		}
		if cfg.APIKey == "" && !strings.Contains(cfg.BaseURL, "localhost") && !strings.Contains(cfg.BaseURL, "127.0.0.1") {
			return heuristic
		}
		primary = &OpenAICompatExtractor{
			APIKey:  cfg.APIKey,
			BaseURL: cfg.BaseURL,
			Model:   cfg.Model,
			Client:  client,
		}
	case "heuristic":
		return heuristic
	default:
		return heuristic
	}

	return &ResilientExtractor{
		Primary:  primary,
		Fallback: heuristic,
	}
}

type ResilientExtractor struct {
	Primary  ExtractorProvider
	Fallback ExtractorProvider
}

func (r *ResilientExtractor) Extract(ctx context.Context, email EmailInput) (Suggestion, error) {
	if r.Primary != nil {
		if s, err := r.Primary.Extract(ctx, email); err == nil && s.Title != "" {
			return normalizeSuggestion(s, email), nil
		}
	}
	return r.Fallback.Extract(ctx, email)
}

func buildPrompt(email EmailInput) string {
	return fmt.Sprintf(`You are an executive assistant extracting an actionable task from an email.
Analyze this email:
Sender: %s
Subject: %s
Content: %s

Return ONLY valid raw JSON (no markdown fences) with these keys:
- "title": concise action-oriented task title (max 10 words)
- "description": brief contextual details
- "categoryId": one of ["work", "personal", "study"]
- "importance": integer 1 (low), 2 (medium), or 3 (urgent)
- "daysUntilDue": integer days until due (e.g. 1 for tomorrow) or null`, email.Sender, email.Subject, email.Snippet)
}

func parseSuggestionJSON(raw string, email EmailInput) (Suggestion, error) {
	clean := strings.TrimSpace(raw)
	clean = strings.TrimPrefix(clean, "```json")
	clean = strings.TrimPrefix(clean, "```")
	clean = strings.TrimSuffix(clean, "```")
	clean = strings.TrimSpace(clean)

	var s Suggestion
	if err := json.Unmarshal([]byte(clean), &s); err != nil {
		return Suggestion{}, err
	}
	return normalizeSuggestion(s, email), nil
}

func normalizeSuggestion(s Suggestion, email EmailInput) Suggestion {
	if strings.TrimSpace(s.Title) == "" {
		s.Title = email.Subject
	}
	if strings.TrimSpace(s.Description) == "" {
		s.Description = email.Snippet
	}
	switch s.CategoryID {
	case "work", "personal", "study":
	default:
		s.CategoryID = "work"
	}
	if s.Importance < 1 || s.Importance > 3 {
		s.Importance = 2
	}
	return s
}

type GeminiExtractor struct {
	APIKey  string
	BaseURL string
	Model   string
	Client  *http.Client
}

func (g *GeminiExtractor) Extract(ctx context.Context, email EmailInput) (Suggestion, error) {
	url := fmt.Sprintf("%s/v1beta/models/%s:generateContent?key=%s", g.BaseURL, g.Model, g.APIKey)
	body := map[string]any{
		"contents": []map[string]any{
			{
				"parts": []map[string]string{
					{"text": buildPrompt(email)},
				},
			},
		},
		"generationConfig": map[string]any{
			"responseMimeType": "application/json",
		},
	}
	payload, err := json.Marshal(body)
	if err != nil {
		return Suggestion{}, err
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bytes.NewReader(payload))
	if err != nil {
		return Suggestion{}, err
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := g.Client.Do(req)
	if err != nil {
		return Suggestion{}, err
	}
	defer resp.Body.Close()

	respBytes, err := io.ReadAll(io.LimitReader(resp.Body, 1<<20))
	if err != nil {
		return Suggestion{}, err
	}
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return Suggestion{}, fmt.Errorf("gemini status %d: %s", resp.StatusCode, string(respBytes))
	}

	var parsed struct {
		Candidates []struct {
			Content struct {
				Parts []struct {
					Text string `json:"text"`
				} `json:"parts"`
			} `json:"content"`
		} `json:"candidates"`
	}
	if err := json.Unmarshal(respBytes, &parsed); err != nil {
		return Suggestion{}, err
	}
	if len(parsed.Candidates) == 0 || len(parsed.Candidates[0].Content.Parts) == 0 {
		return Suggestion{}, fmt.Errorf("gemini returned empty candidates")
	}
	return parseSuggestionJSON(parsed.Candidates[0].Content.Parts[0].Text, email)
}

type OpenAICompatExtractor struct {
	APIKey  string
	BaseURL string
	Model   string
	Client  *http.Client
}

func (o *OpenAICompatExtractor) Extract(ctx context.Context, email EmailInput) (Suggestion, error) {
	url := fmt.Sprintf("%s/chat/completions", o.BaseURL)
	body := map[string]any{
		"model": o.Model,
		"messages": []map[string]string{
			{"role": "system", "content": "Extract structured task JSON from emails. Return raw JSON only."},
			{"role": "user", "content": buildPrompt(email)},
		},
		"temperature": 0.1,
	}
	payload, err := json.Marshal(body)
	if err != nil {
		return Suggestion{}, err
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bytes.NewReader(payload))
	if err != nil {
		return Suggestion{}, err
	}
	req.Header.Set("Content-Type", "application/json")
	if o.APIKey != "" {
		req.Header.Set("Authorization", "Bearer "+o.APIKey)
	}

	resp, err := o.Client.Do(req)
	if err != nil {
		return Suggestion{}, err
	}
	defer resp.Body.Close()

	respBytes, err := io.ReadAll(io.LimitReader(resp.Body, 1<<20))
	if err != nil {
		return Suggestion{}, err
	}
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return Suggestion{}, fmt.Errorf("openai_compat status %d: %s", resp.StatusCode, string(respBytes))
	}

	var parsed struct {
		Choices []struct {
			Message struct {
				Content string `json:"content"`
			} `json:"message"`
		} `json:"choices"`
	}
	if err := json.Unmarshal(respBytes, &parsed); err != nil {
		return Suggestion{}, err
	}
	if len(parsed.Choices) == 0 {
		return Suggestion{}, fmt.Errorf("openai_compat returned empty choices")
	}
	return parseSuggestionJSON(parsed.Choices[0].Message.Content, email)
}

type HeuristicExtractor struct{}

func (h *HeuristicExtractor) Extract(_ context.Context, email EmailInput) (Suggestion, error) {
	lower := strings.ToLower(email.Subject + " " + email.Snippet)
	importance := 1
	category := "personal"
	days := 2

	if strings.Contains(lower, "urgent") ||
		strings.Contains(lower, "asap") ||
		strings.Contains(lower, "immediately") ||
		strings.Contains(lower, "invoice") ||
		strings.Contains(lower, "penalty") ||
		strings.Contains(lower, "due") {
		importance = 3
	} else if strings.Contains(lower, "review") ||
		strings.Contains(lower, "check-in") ||
		strings.Contains(lower, "reminder") {
		importance = 2
	}

	if strings.Contains(lower, "invoice") ||
		strings.Contains(lower, "sprint") ||
		strings.Contains(lower, "meeting") ||
		strings.Contains(lower, "client") ||
		strings.Contains(lower, "payment") {
		category = "work"
	} else if strings.Contains(lower, "assignment") ||
		strings.Contains(lower, "lab") ||
		strings.Contains(lower, "university") ||
		strings.Contains(lower, "exam") ||
		strings.Contains(lower, "homework") {
		category = "study"
	}

	if strings.Contains(lower, "tomorrow") || strings.Contains(lower, "24 hours") {
		days = 1
	} else if strings.Contains(lower, "friday") {
		days = 3
	}

	title := strings.TrimSpace(email.Subject)
	for _, prefix := range []string{"Re: ", "RE: ", "Fwd: ", "FWD: "} {
		title = strings.TrimPrefix(title, prefix)
	}
	if title == "" {
		title = "Follow up on email from " + email.Sender
	}

	return Suggestion{
		Title:        title,
		Description:  fmt.Sprintf("Extracted from email from %s:\n%q", email.Sender, email.Snippet),
		CategoryID:   category,
		Importance:   importance,
		DaysUntilDue: &days,
	}, nil
}
