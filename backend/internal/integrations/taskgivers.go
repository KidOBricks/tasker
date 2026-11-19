package integrations

import (
	"crypto/rand"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"html"
	"net/http"
	"net/mail"
	"strconv"
	"strings"
	"time"

	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/tools/mailer"
)

func RegisterTaskgiverHooks(app core.App) {
	app.OnRecordAfterUpdateSuccess("tasks").BindFunc(func(e *core.RecordEvent) error {
		rec := e.Record
		if rec == nil || rec.GetString("status") != "completed" {
			return e.Next()
		}
		if orig := rec.Original(); orig != nil && orig.GetString("status") == "completed" {
			return e.Next()
		}
		giverID := strings.TrimSpace(rec.GetString("givenById"))
		if giverID == "" {
			return e.Next()
		}
		if !app.Settings().SMTP.Enabled {
			return e.Next()
		}

		giver, err := app.FindRecordById("trusted_taskgivers", giverID)
		if err != nil || giver == nil {
			return e.Next()
		}
		toEmail := strings.TrimSpace(giver.GetString("email"))
		if toEmail == "" {
			return e.Next()
		}

		msg := &mailer.Message{
			From: mail.Address{
				Name:    app.Settings().Meta.SenderName,
				Address: app.Settings().Meta.SenderAddress,
			},
			To:      []mail.Address{{Name: giver.GetString("name"), Address: toEmail}},
			Subject: fmt.Sprintf("Task completed: %s", rec.GetString("title")),
			Text: fmt.Sprintf(
				"Hi %s,\n\nYour requested task \"%s\" was just marked completed in Tasker.\n",
				giver.GetString("name"),
				rec.GetString("title"),
			),
		}
		_ = app.NewMailClient().Send(msg)
		return e.Next()
	})
}

func (s *Service) registerTaskgiverRoutes(se *core.ServeEvent) {
	se.Router.POST("/api/taskgivers", s.handleCreateTaskgiver).Bind(apis.RequireAuth("users"))
	se.Router.GET("/give/{token}", s.handlePublicTaskgiverPage)
	se.Router.POST("/api/give/{token}/tasks", s.handlePublicCreateTask)
}

func generateSecureToken(numBytes int) (string, error) {
	buf := make([]byte, numBytes)
	if _, err := rand.Read(buf); err != nil {
		return "", err
	}
	return base64.RawURLEncoding.EncodeToString(buf), nil
}

func (s *Service) handleCreateTaskgiver(e *core.RequestEvent) error {
	var body struct {
		Name  string `json:"name"`
		Email string `json:"email"`
	}
	if err := e.BindBody(&body); err != nil {
		return e.BadRequestError("invalid request body", err)
	}
	name := strings.TrimSpace(body.Name)
	if name == "" {
		return e.BadRequestError("name is required", nil)
	}
	token, err := generateSecureToken(24)
	if err != nil {
		return e.InternalServerError("failed to generate token", err)
	}

	col, err := s.App.FindCollectionByNameOrId("trusted_taskgivers")
	if err != nil {
		return e.InternalServerError("trusted_taskgivers collection missing", err)
	}

	rec := core.NewRecord(col)
	rec.Set("user", e.Auth.Id)
	rec.Set("name", name)
	rec.Set("email", strings.TrimSpace(body.Email))
	rec.Set("token", token)
	rec.Set("isActive", true)

	if err := s.App.Save(rec); err != nil {
		return e.InternalServerError("failed to save taskgiver", err)
	}

	return e.JSON(http.StatusCreated, map[string]any{
		"id":       rec.Id,
		"name":     rec.GetString("name"),
		"email":    rec.GetString("email"),
		"token":    token,
		"isActive": true,
		"shareUrl": s.PublicURL + "/give/" + token,
	})
}

func (s *Service) findActiveTaskgiverByToken(token string) (*core.Record, error) {
	clean := strings.TrimSpace(token)
	if clean == "" {
		return nil, fmt.Errorf("missing token")
	}
	rec, err := s.App.FindFirstRecordByFilter(
		"trusted_taskgivers",
		"token = {:tok} && isActive = true",
		map[string]any{"tok": clean},
	)
	if err != nil || rec == nil {
		return nil, fmt.Errorf("invalid or revoked link")
	}
	return rec, nil
}

func loadOwnerPriorityConfig(app core.App, userID string) (int, map[int]string) {
	numLevels := 3
	names := map[int]string{
		1: "Level 1 (Low)",
		2: "Level 2 (Medium)",
		3: "Level 3 (Urgent)",
		4: "Level 4 (Critical)",
		5: "Level 5 (Emergency)",
	}

	profile, err := app.FindFirstRecordByFilter(
		"user_profiles",
		"user = {:uid}",
		map[string]any{"uid": userID},
	)
	if err != nil || profile == nil {
		return numLevels, names
	}

	if n := profile.GetInt("numImportanceLevels"); n >= 3 && n <= 5 {
		numLevels = n
	}

	raw := profile.GetString("levelNames")
	if strings.TrimSpace(raw) != "" {
		var parsed map[string]any
		if json.Unmarshal([]byte(raw), &parsed) == nil {
			for k, v := range parsed {
				lvl, err := strconv.Atoi(strings.TrimSpace(k))
				if err != nil || lvl < 1 || lvl > 5 {
					continue
				}
				label := strings.TrimSpace(fmt.Sprint(v))
				if label != "" && v != nil {
					names[lvl] = label
				}
			}
		}
	}
	return numLevels, names
}

func priorityLabelFor(level, numLevels int, names map[int]string) string {
	if level < 1 {
		level = 1
	}
	if level > numLevels {
		level = numLevels
	}
	if label := strings.TrimSpace(names[level]); label != "" {
		return label
	}
	return fmt.Sprintf("Level %d", level)
}

func (s *Service) handlePublicTaskgiverPage(e *core.RequestEvent) error {
	token := e.Request.PathValue("token")
	giver, err := s.findActiveTaskgiverByToken(token)
	if err != nil {
		return e.HTML(http.StatusNotFound, renderTaskgiverErrorHTML("This task link is invalid or has been revoked."))
	}

	ownerID := giver.GetString("user")
	ownerName := "Tasker User"
	if owner, err := s.App.FindRecordById("users", ownerID); err == nil && owner != nil {
		if dn := strings.TrimSpace(owner.GetString("displayName")); dn != "" {
			ownerName = dn
		}
	}

	numLevels, levelNames := loadOwnerPriorityConfig(s.App, ownerID)

	tasks, _ := s.App.FindRecordsByFilter(
		"tasks",
		"givenById = {:gid} && (deletedAt = '' || deletedAt = null)",
		"-created",
		100,
		0,
		map[string]any{"gid": giver.Id},
	)

	return e.HTML(http.StatusOK, renderTaskgiverPageHTML(token, giver.GetString("name"), ownerName, numLevels, levelNames, tasks))
}

func (s *Service) handlePublicCreateTask(e *core.RequestEvent) error {
	token := e.Request.PathValue("token")
	giver, err := s.findActiveTaskgiverByToken(token)
	if err != nil {
		return e.NotFoundError("invalid or revoked link", err)
	}

	var body struct {
		Title           string `json:"title" form:"title"`
		Description     string `json:"description" form:"description"`
		DueDate         string `json:"dueDate" form:"dueDate"`
		DueTime         string `json:"dueTime" form:"dueTime"`
		TzOffsetMinutes *int   `json:"tzOffsetMinutes" form:"tzOffsetMinutes"`
		Importance      int    `json:"importance" form:"importance"`
		Website         string `json:"website" form:"website"` // honeypot
	}
	if err := e.BindBody(&body); err != nil {
		return e.BadRequestError("invalid submission", err)
	}
	if strings.TrimSpace(body.Website) != "" {
		return e.BadRequestError("invalid submission", nil)
	}

	title := strings.TrimSpace(body.Title)
	if title == "" {
		return e.BadRequestError("title is required", nil)
	}
	if len(title) > 300 {
		title = title[:300]
	}

	ownerID := giver.GetString("user")
	numLevels, levelNames := loadOwnerPriorityConfig(s.App, ownerID)
	imp := body.Importance
	if imp < 1 || imp > numLevels {
		imp = 2
		if imp > numLevels {
			imp = numLevels
		}
	}

	dueISO := parseTaskgiverDueDate(body.DueDate, body.DueTime, body.TzOffsetMinutes)

	col, err := s.App.FindCollectionByNameOrId("tasks")
	if err != nil {
		return e.InternalServerError("tasks collection missing", err)
	}
	clientSuffix, _ := generateSecureToken(8)
	nowISO := time.Now().UTC().Format(time.RFC3339)

	rec := core.NewRecord(col)
	rec.Set("user", ownerID)
	rec.Set("clientId", "tg_"+clientSuffix)
	rec.Set("title", title)
	rec.Set("description", strings.TrimSpace(body.Description))
	rec.Set("categoryId", "all")
	rec.Set("baseImportance", imp)
	rec.Set("effectiveImportance", imp)
	rec.Set("dueDate", dueISO)
	rec.Set("status", "pending")
	rec.Set("isOverdue", false)
	rec.Set("clientCreatedAt", nowISO)
	rec.Set("clientUpdatedAt", nowISO)
	rec.Set("givenById", giver.Id)
	rec.Set("givenByName", giver.GetString("name"))

	if err := s.App.Save(rec); err != nil {
		return e.InternalServerError("failed to save task", err)
	}

	// Non-JS progressive enhancement fallback
	accept := e.Request.Header.Get("Accept")
	if !strings.Contains(accept, "application/json") {
		return e.Redirect(http.StatusSeeOther, "/give/"+token)
	}

	return e.JSON(http.StatusCreated, map[string]any{
		"id":              rec.Id,
		"clientId":        rec.GetString("clientId"),
		"title":           rec.GetString("title"),
		"status":          rec.GetString("status"),
		"dueDate":         rec.GetString("dueDate"),
		"importance":      imp,
		"importanceLabel": priorityLabelFor(imp, numLevels, levelNames),
		"created":         nowISO,
	})
}

func parseTaskgiverDueDate(rawDue, rawTime string, tzOffsetMinutes *int) string {
	rawDue = strings.TrimSpace(rawDue)
	if rawDue == "" {
		return ""
	}
	if t, err := time.Parse(time.RFC3339, rawDue); err == nil {
		return t.UTC().Format(time.RFC3339)
	}
	loc := time.UTC
	if tzOffsetMinutes != nil && *tzOffsetMinutes >= -840 && *tzOffsetMinutes <= 840 {
		// JS getTimezoneOffset returns UTC - local in minutes (e.g. -60 for UTC+1).
		loc = time.FixedZone("client", -(*tzOffsetMinutes)*60)
	}
	if t, err := time.ParseInLocation("2006-01-02T15:04", rawDue, loc); err == nil {
		return t.UTC().Format(time.RFC3339)
	}
	d, err := time.Parse("2006-01-02", rawDue)
	if err != nil {
		return ""
	}
	hour, min := 18, 0
	if cleanTime := strings.TrimSpace(rawTime); cleanTime != "" {
		for _, layout := range []string{"15:04", "15:04:05"} {
			if pt, err := time.Parse(layout, cleanTime); err == nil {
				hour, min = pt.Hour(), pt.Minute()
				break
			}
		}
	}
	return time.Date(d.Year(), d.Month(), d.Day(), hour, min, 0, 0, loc).UTC().Format(time.RFC3339)
}

func renderTaskgiverErrorHTML(message string) string {
	return fmt.Sprintf(`<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Tasker — Link Unavailable</title>
  <style>
    body { font-family: system-ui, sans-serif; background: #161614; color: #ECE9E2; display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; padding: 1.5rem; }
    main { background: #1F1F1C; border: 1px solid #32312C; border-radius: 12px; padding: 2rem; max-width: 440px; text-align: center; }
    h1 { font-size: 1.25rem; margin-top: 0; }
    p { color: #A6A196; line-height: 1.5; }
  </style>
</head>
<body>
  <main>
    <h1>Link unavailable</h1>
    <p>%s</p>
  </main>
</body>
</html>`, html.EscapeString(message))
}

func renderTaskgiverPageHTML(token, giverName, ownerName string, numLevels int, levelNames map[int]string, tasks []*core.Record) string {
	var listItems strings.Builder
	if len(tasks) == 0 {
		listItems.WriteString(`<li class="empty-item">No tasks sent yet. Use the form above to add one.</li>`)
	} else {
		for _, t := range tasks {
			status := t.GetString("status")
			label := "Pending"
			cls := "badge-pending"
			switch status {
			case "in_progress":
				label = "In progress"
				cls = "badge-progress"
			case "completed":
				label = "Completed"
				cls = "badge-done"
			case "ignored":
				label = "Skipped"
				cls = "badge-ignored"
			}
			dueHtml := ""
			if due := strings.TrimSpace(t.GetString("dueDate")); due != "" {
				dueFallback := due
				if parsed, err := time.Parse(time.RFC3339, due); err == nil {
					dueFallback = parsed.UTC().Format("2006-01-02 15:04 UTC")
				} else if len(dueFallback) >= 10 {
					dueFallback = dueFallback[:10]
				}
				dueHtml = fmt.Sprintf(
					`<span class="meta" data-due-iso="%s">Due %s</span>`,
					html.EscapeString(due),
					html.EscapeString(dueFallback),
				)
			}
			imp := t.GetInt("baseImportance")
			if imp < 1 {
				imp = 1
			}
			impLabel := priorityLabelFor(imp, numLevels, levelNames)
			impHtml := fmt.Sprintf(`<span class="meta">Priority: %s</span>`, html.EscapeString(impLabel))
			listItems.WriteString(fmt.Sprintf(
				`<li class="task-row"><div><div class="task-title">%s</div>%s%s</div><span class="badge %s">%s</span></li>`,
				html.EscapeString(t.GetString("title")),
				impHtml,
				dueHtml,
				cls,
				label,
			))
		}
	}

	var priorityRadios strings.Builder
	defaultImp := 2
	if defaultImp > numLevels {
		defaultImp = numLevels
	}
	for lvl := 1; lvl <= numLevels; lvl++ {
		checkedAttr := ""
		if lvl == defaultImp {
			checkedAttr = " checked"
		}
		lbl := html.EscapeString(priorityLabelFor(lvl, numLevels, levelNames))
		priorityRadios.WriteString(fmt.Sprintf(
			`<label class="radio-opt" for="imp-%d"><input type="radio" id="imp-%d" name="importance" value="%d"%s><span>%s</span></label>`,
			lvl, lvl, lvl, checkedAttr, lbl,
		))
	}

	escToken := html.EscapeString(token)
	escGiver := html.EscapeString(giverName)
	escOwner := html.EscapeString(ownerName)

	// Serialize task data safely for live client updates after AJAX submission
	initialJSON, _ := json.Marshal(len(tasks))

	return fmt.Sprintf(`<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Send Task to %s — Tasker</title>
  <style>
    :root {
      color-scheme: dark;
      --bg: #161614;
      --surface: #1F1F1C;
      --surface-2: #292824;
      --border: #363530;
      --text: #ECE9E2;
      --muted: #A6A196;
      --accent: #3CA89C;
      --danger: #E5484D;
      --ok: #3EB489;
      --warn: #E09F3E;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: system-ui, -apple-system, sans-serif;
      background: var(--bg);
      color: var(--text);
      line-height: 1.5;
      padding: 1.5rem 1rem 3rem;
    }
    main { max-width: 640px; margin: 0 auto; display: grid; gap: 1.5rem; }
    header h1 { margin: 0 0 0.25rem; font-size: 1.5rem; font-weight: 600; }
    header p { margin: 0; color: var(--muted); }
    .card {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 1.25rem;
    }
    h2 { margin: 0 0 1rem; font-size: 1.05rem; font-weight: 600; }
    .field { display: flex; flex-direction: column; gap: 0.35rem; margin-block-end: 1.15rem; }
    .field-row { display: grid; grid-template-columns: 1fr; gap: 0.9rem; margin-block-end: 1.15rem; }
    .field-row .field { margin-block-end: 0; }
    @media (min-width: 480px) {
      .field-row { grid-template-columns: 1fr 1fr; }
    }
    label { font-size: 0.92rem; font-weight: 500; }
    .hint { font-size: 0.82rem; color: var(--muted); }
    input, textarea, select {
      font: inherit;
      font-size: max(1rem, 1em);
      color: var(--text);
      background: var(--surface-2);
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 0.7rem 0.85rem;
      min-height: 48px;
      width: 100%%;
    }
    textarea { min-height: 96px; resize: vertical; }
    input:focus-visible, textarea:focus-visible, select:focus-visible, button:focus-visible {
      outline: 3px solid var(--accent);
      outline-offset: 2px;
    }
    :is(:user-invalid, .user-invalid-fallback) { border-color: var(--danger); }
    .error-msg { display: none; color: #FF8A8E; font-size: 0.85rem; }
    :is(:user-invalid, .user-invalid-fallback) ~ .error-msg { display: block; }
    fieldset { border: 1px solid var(--border); border-radius: 8px; padding: 0.75rem 1rem; margin: 0 0 1.15rem; }
    legend { padding: 0 0.4rem; font-size: 0.9rem; font-weight: 500; }
    .radio-row { display: flex; gap: 1rem; flex-wrap: wrap; }
    .radio-opt { display: inline-flex; align-items: center; gap: 0.45rem; min-height: 44px; cursor: pointer; }
    .radio-opt input { width: auto; min-height: auto; accent-color: var(--accent); }
    button[type="submit"] {
      font: inherit;
      font-weight: 600;
      min-height: 48px;
      padding: 0.75rem 1.25rem;
      border: 0;
      border-radius: 8px;
      background: var(--accent);
      color: #0D1615;
      cursor: pointer;
      width: 100%%;
    }
    button[disabled] { opacity: 0.6; cursor: wait; }
    .status-banner { display: none; padding: 0.75rem 1rem; border-radius: 8px; margin-bottom: 1rem; font-size: 0.9rem; }
    .status-banner.ok { display: block; background: rgba(62,180,137,0.16); border: 1px solid var(--ok); }
    .status-banner.err { display: block; background: rgba(229,72,77,0.16); border: 1px solid var(--danger); }
    .task-list { list-style: none; padding: 0; margin: 0; display: grid; gap: 0.65rem; }
    .task-row {
      display: flex; align-items: center; justify-content: space-between; gap: 0.75rem;
      padding: 0.75rem 0.9rem; background: var(--surface-2); border-radius: 8px; border: 1px solid var(--border);
    }
    .task-title { font-weight: 500; }
    .meta { display: block; font-size: 0.8rem; color: var(--muted); }
    .empty-item { color: var(--muted); font-size: 0.9rem; }
    .badge { font-size: 0.78rem; padding: 0.25rem 0.6rem; border-radius: 999px; font-weight: 600; white-space: nowrap; }
    .badge-pending { background: rgba(224,159,62,0.18); color: #F5C36D; }
    .badge-progress { background: rgba(60,168,156,0.2); color: #7EE0D5; }
    .badge-done { background: rgba(62,180,137,0.2); color: #7BE0B8; }
    .badge-ignored { background: rgba(166,161,150,0.16); color: var(--muted); }
    .visually-hidden:where(:not(:focus-within, :active)) {
      position: absolute !important; clip-path: inset(50%%) !important; overflow: hidden !important;
      width: 1px !important; height: 1px !important; margin: -1px !important; padding: 0 !important; border: 0 !important; white-space: nowrap !important;
    }
  </style>
</head>
<body>
  <main>
    <header>
      <h1>Add a task for %s</h1>
      <p>Trusted link for <strong>%s</strong></p>
    </header>

    <section class="card" aria-labelledby="form-heading">
      <h2 id="form-heading">New task</h2>
      <div id="submit-status" class="status-banner" role="status" aria-live="polite"></div>

      <form id="give-form" action="/api/give/%s/tasks" method="POST" aria-labelledby="form-heading" novalidate>
        <div class="visually-hidden" aria-hidden="true">
          <label for="website">Leave blank</label>
          <input type="text" id="website" name="website" tabindex="-1" autocomplete="off">
        </div>

        <div class="field">
          <label for="title">Task title <span aria-hidden="true">*</span></label>
          <span id="title-hint" class="hint">Short, actionable summary (max 300 characters).</span>
          <input type="text" id="title" name="title" required maxlength="300" autocomplete="off"
                 aria-describedby="title-hint" data-error="title-error" enterkeyhint="next">
          <span id="title-error" class="error-msg"><span role="img" aria-label="Error">!</span> Please enter a task title.</span>
        </div>

        <div class="field">
          <label for="description">Details (optional)</label>
          <textarea id="description" name="description" maxlength="4000" placeholder="Links, context, or instructions..."></textarea>
        </div>

        <div class="field-row">
          <div class="field">
            <label for="dueDate">Due date (optional)</label>
            <input type="date" id="dueDate" name="dueDate" data-error="due-error">
            <span id="due-error" class="error-msg"><span role="img" aria-label="Error">!</span> Pick a due date when setting a due time.</span>
          </div>
          <div class="field">
            <label for="dueTime">Due time (optional)</label>
            <input type="time" id="dueTime" name="dueTime" aria-describedby="due-time-hint">
            <span id="due-time-hint" class="hint">Defaults to 6:00 PM if date is set.</span>
          </div>
        </div>
        <input type="hidden" id="tzOffsetMinutes" name="tzOffsetMinutes" value="">

        <fieldset>
          <legend>Priority</legend>
          <div class="radio-row">
            %s
          </div>
        </fieldset>

        <button type="submit" id="submit-btn">Send task to %s</button>
      </form>
    </section>

    <section class="card" aria-labelledby="history-heading">
      <h2 id="history-heading">Tasks you requested (<span id="task-count">%s</span>)</h2>
      <ul id="task-list" class="task-list">%s</ul>
    </section>
  </main>

  <script>
    (() => {
      const form = document.getElementById('give-form');
      const submitBtn = document.getElementById('submit-btn');
      const statusBox = document.getElementById('submit-status');
      const taskList = document.getElementById('task-list');
      const taskCount = document.getElementById('task-count');
      const dueDateInput = document.getElementById('dueDate');
      const dueTimeInput = document.getElementById('dueTime');
      const tzInput = document.getElementById('tzOffsetMinutes');
      const syncTz = () => {
        if (tzInput) tzInput.value = String(new Date().getTimezoneOffset());
      };
      syncTz();

      const formatDue = (iso) => {
        const dt = new Date(iso);
        if (Number.isNaN(dt.getTime())) return iso.slice(0, 10);
        return dt.toLocaleString(undefined, { dateStyle: 'medium', timeStyle: 'short' });
      };
      document.querySelectorAll('[data-due-iso]').forEach((el) => {
        el.textContent = 'Due ' + formatDue(el.dataset.dueIso);
      });

      // Accessible :user-invalid + aria-invalid synchronization
      const announcer = document.createElement('div');
      announcer.setAttribute('aria-live', 'polite');
      announcer.classList.add('visually-hidden');
      document.body.append(announcer);

      const linkError = (el, shown) => {
        const errorId = el.dataset.error;
        if (!errorId) return;
        const ids = (el.getAttribute('aria-describedby') || '').split(/\s+/).filter((id) => id && id !== errorId);
        if (shown) ids.push(errorId);
        if (ids.length) el.setAttribute('aria-describedby', ids.join(' '));
        else el.removeAttribute('aria-describedby');
      };

      const syncDueValidity = () => {
        if (dueTimeInput.value && !dueDateInput.value) {
          dueDateInput.setCustomValidity('Pick a due date when setting a due time.');
        } else {
          dueDateInput.setCustomValidity('');
        }
      };

      const syncField = (el, shouldAnnounce = false) => {
        if (!el.matches?.('input, textarea, select')) return;
        const invalid = el.matches(':user-invalid') || !el.validity.valid && el.classList.contains('user-invalid-fallback');
        el.setAttribute('aria-invalid', invalid ? 'true' : 'false');
        linkError(el, invalid);
        if (invalid && shouldAnnounce) {
          const err = document.getElementById(el.dataset.error);
          if (err) announcer.textContent = err.textContent.trim();
        }
      };

      form.querySelectorAll('input, textarea, select').forEach((el) => el.setAttribute('aria-invalid', 'false'));
      form.addEventListener('blur', (e) => {
        syncDueValidity();
        if (!e.target.checkValidity?.()) e.target.classList.add('user-invalid-fallback');
        syncField(e.target, true);
      }, true);
      form.addEventListener('input', (e) => {
        syncDueValidity();
        if (dueDateInput.validity?.valid) {
          dueDateInput.classList.remove('user-invalid-fallback');
          syncField(dueDateInput, false);
        }
        if (e.target.validity?.valid) e.target.classList.remove('user-invalid-fallback');
        syncField(e.target, false);
      });

      form.addEventListener('submit', async (e) => {
        e.preventDefault();
        syncDueValidity();
        const titleInput = document.getElementById('title');
        if (!form.checkValidity()) {
          const firstInvalid = !titleInput.validity.valid ? titleInput : dueDateInput;
          firstInvalid.classList.add('user-invalid-fallback');
          syncField(firstInvalid, true);
          firstInvalid.focus();
          return;
        }

        submitBtn.disabled = true;
        statusBox.className = 'status-banner';
        statusBox.textContent = '';

        const fd = new FormData(form);
        const payload = {
          title: fd.get('title') || '',
          description: fd.get('description') || '',
          dueDate: fd.get('dueDate') || '',
          dueTime: fd.get('dueTime') || '',
          tzOffsetMinutes: new Date().getTimezoneOffset(),
          importance: Number(fd.get('importance') || 2),
          website: fd.get('website') || ''
        };

        try {
          const resp = await fetch(form.action, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
            body: JSON.stringify(payload)
          });
          if (!resp.ok) throw new Error('Request failed');
          const created = await resp.json();

          const empty = taskList.querySelector('.empty-item');
          if (empty) empty.remove();

          const li = document.createElement('li');
          li.className = 'task-row';
          const left = document.createElement('div');
          const tDiv = document.createElement('div');
          tDiv.className = 'task-title';
          tDiv.textContent = created.title;
          left.append(tDiv);
          if (created.importanceLabel) {
            const pMeta = document.createElement('span');
            pMeta.className = 'meta';
            pMeta.textContent = 'Priority: ' + created.importanceLabel;
            left.append(pMeta);
          }
          if (created.dueDate) {
            const meta = document.createElement('span');
            meta.className = 'meta';
            meta.dataset.dueIso = created.dueDate;
            meta.textContent = 'Due ' + formatDue(created.dueDate);
            left.append(meta);
          }
          const badge = document.createElement('span');
          badge.className = 'badge badge-pending';
          badge.textContent = 'Pending';
          li.append(left, badge);
          taskList.prepend(li);

          taskCount.textContent = String(Number(taskCount.textContent || '0') + 1);
          statusBox.className = 'status-banner ok';
          statusBox.textContent = 'Task sent! ' + created.title;
          form.reset();
          syncTz();
          form.querySelectorAll('input, textarea').forEach((el) => {
            el.classList.remove('user-invalid-fallback');
            el.setAttribute('aria-invalid', 'false');
            linkError(el, false);
          });
        } catch (_) {
          statusBox.className = 'status-banner err';
          statusBox.textContent = 'Could not send task. Please check the link and try again.';
        } finally {
          submitBtn.disabled = false;
        }
      });
    })();
  </script>
</body>
</html>`, escOwner, escOwner, escGiver, escToken, priorityRadios.String(), escOwner, string(initialJSON), listItems.String())
}
