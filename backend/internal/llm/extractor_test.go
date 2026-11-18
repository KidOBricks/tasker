package llm

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestGeminiExtractorAndFallback(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		resp := map[string]any{
			"candidates": []map[string]any{
				{
					"content": map[string]any{
						"parts": []map[string]string{
							{"text": `{"title":"Pay Cloud Invoice","description":"Due Friday","categoryId":"work","importance":3,"daysUntilDue":2}`},
						},
					},
				},
			},
		}
		_ = json.NewEncoder(w).Encode(resp)
	}))
	defer srv.Close()

	ext := NewExtractorFromConfig(Config{
		Provider: "gemini",
		APIKey:   "test-key",
		BaseURL:  srv.URL,
	}, srv.Client())

	s, err := ext.Extract(context.Background(), EmailInput{
		Sender:  "billing@cloud.io",
		Subject: "Invoice #9482",
		Snippet: "Please pay by Friday",
	})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if s.Title != "Pay Cloud Invoice" || s.CategoryID != "work" || s.Importance != 3 {
		t.Fatalf("unexpected suggestion: %+v", s)
	}
}

func TestOpenAICompatExtractorFallsBackOnServerError(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		http.Error(w, "rate limited", http.StatusTooManyRequests)
	}))
	defer srv.Close()

	ext := NewExtractorFromConfig(Config{
		Provider: "openai_compat",
		APIKey:   "test-key",
		BaseURL:  srv.URL,
		Model:    "llama-3.1-8b-instant",
	}, srv.Client())

	s, err := ext.Extract(context.Background(), EmailInput{
		Sender:  "prof@university.edu",
		Subject: "Re: Lab 3 Assignment Due Tomorrow",
		Snippet: "Late penalties apply",
	})
	if err != nil {
		t.Fatalf("expected heuristic fallback without error, got %v", err)
	}
	if s.CategoryID != "study" || s.Importance != 3 {
		t.Fatalf("expected study + importance 3 from heuristic fallback, got %+v", s)
	}
	if s.DaysUntilDue == nil || *s.DaysUntilDue != 1 {
		t.Fatalf("expected 1 day until due, got %+v", s.DaysUntilDue)
	}
}

func TestBulkExtractGeminiAndHeuristic(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		resp := map[string]any{
			"candidates": []map[string]any{
				{
					"content": map[string]any{
						"parts": []map[string]string{
							{"text": `[{"title":"Submit lab report","description":"","categoryId":"study","importance":3},{"title":"Buy coffee beans","description":"","categoryId":"personal","importance":1}]`},
						},
					},
				},
			},
		}
		_ = json.NewEncoder(w).Encode(resp)
	}))
	defer srv.Close()

	ext := NewExtractorFromConfig(Config{
		Provider: "gemini",
		APIKey:   "test-key",
		BaseURL:  srv.URL,
	}, srv.Client())

	drafts, err := ext.ExtractBulk(context.Background(), "submit lab report and buy coffee")
	if err != nil {
		t.Fatalf("ExtractBulk failed: %v", err)
	}
	if len(drafts) != 2 || drafts[0].CategoryID != "study" || drafts[1].Title != "Buy coffee beans" {
		t.Fatalf("unexpected bulk drafts: %+v", drafts)
	}

	heur := &HeuristicExtractor{}
	hDrafts, err := heur.ExtractBulk(context.Background(), "- [ ] Urgent invoice check\n2. Read exam notes\n")
	if err != nil {
		t.Fatalf("Heuristic ExtractBulk failed: %v", err)
	}
	if len(hDrafts) != 2 || hDrafts[0].Importance != 3 || hDrafts[1].CategoryID != "study" {
		t.Fatalf("unexpected heuristic drafts: %+v", hDrafts)
	}
}
