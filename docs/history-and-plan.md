# Tasker — Project History & Current Plan

This document preserves the full context, design evolution, and next steps from the initial cloud design sessions so local development can pick up immediately without losing history.

---

## 1. Timeline of Work Completed

### Phase A — Design & Flutter v1 Prototype (`main`, Nov 11–12, 2026)
1. **Design Lock (`/grill-me` session)**:
   - Locked core domain mechanics: Dynamic Priority Escalation (`baseImportance` vs. `effectiveImportance`), Dual-Visibility In-Progress tasks, Sequential Cycle Catch-up recurrence, Vacation Mode, Analytics suite (4-column stacked chart, heatmap, late-chore leaderboard, CSV/JSON export), and adaptive mobile/desktop layouts.
   - Captured in [`docs/architecture-and-roadmap.md`](architecture-and-roadmap.md).
2. **Initial Flutter Implementation (`d7f0dea` -> `3ec83b5`)**:
   - Built core domain engines (`PriorityEngine`, `RecurrenceEngine`, `AnalyticsEngine`), Riverpod state management, adaptive 5-tab client UI (`Tasks`, `Calendar`, `Progress`, `Ideas`, `Settings`), Web scaffolding, and an initial mocked `web/admin.html` + `AdminConsoleScreen` prototype.
   - Verified with 26 passing tests and `flutter analyze` (0 issues). See [`docs/walkthrough-v1.md`](walkthrough-v1.md).

### Phase B — Self-Hosted Production Architecture (`feat/production-pocketbase-sync` -> merged to `main` in PR #1, Nov 16–18, 2026)
After reviewing Firebase/client-side limitations, the architecture was rebuilt on a **self-hosted PocketBase + Drift** stack and merged into `main` (`ded6f6e`):
- **Plan Document**: [`docs/pocketbase-implementation-plan.md`](pocketbase-implementation-plan.md).
- **Merged PR #1**: [`feat: PocketBase Go backend, Drift offline sync, and OCI sslip.io deployment`](https://github.com/KidOBricks/tasker/pull/1):
  - **`134deb1`**: Added Go PocketBase backend (`backend/`), idempotent collection schema (`users`, `user_profiles`, `categories`, `recurrence_rules`, `tasks`, `oauth_connections`, `external_events`, `task_suggestions`), AES-256-GCM OAuth token vault, Google/Outlook Calendar + Gmail sync routes & 15-min cron, pluggable LLM extractor (`gemini` / `groq` / `openrouter` / `openai_compat` / `heuristic`), Drift SQLite offline-first client sync + Web WASM assets, Android `tasker://oauth-callback` deep link, invite-only `AuthScreen`, OCI `sslip.io` + Caddy deployment scripts (`deploy/`), GitHub Actions CI/CD (`.github/workflows/ci.yml`), and removal of mocked `web/admin.html` / `AdminConsoleScreen`.
  - **`995757b`**: Rebuilt UI and web shell with the **Warm Graphite** design system and self-hosted CanvasKit.
  - **Verification recorded on PR #1**: `go test -count=1 -v ./...` passed (crypto, integrations, llm), `flutter analyze --no-fatal-infos` passed with 0 errors/warnings, `flutter test` passed (23/23), `flutter build web --release` succeeded.

---

## 2. Current State & What Remains Next

### Immediate Next Steps
1. **Run locally (optional)**: Start PocketBase locally (`cd backend && go run . serve --http=127.0.0.1:8090`) and run Flutter against it (`flutter run -d windows` or `chrome` with `--dart-define=TASKER_API_URL=http://127.0.0.1:8090`).
2. **Provision Oracle Cloud (OCI) Always Free ARM64 VM** and run `sudo bash deploy/oci-setup.sh --ip <YOUR_OCI_PUBLIC_IP>` (see [`README.md`](../README.md)).
3. **Configure OAuth2 Consent & Credentials**:
   - **Google Cloud Console**: Enable Calendar API & Gmail API, add test users, register `https://<dashed-ip>.sslip.io/api/integrations/google/callback` and `/api/oauth2-redirect`.
   - **Microsoft Entra ID**: Enable `Calendars.Read`, `offline_access`, `User.Read`, register `/api/integrations/microsoft/callback` and `/api/oauth2-redirect`.
   - Populate `/opt/tasker/.env` (`GOOGLE_CLIENT_*`, `MICROSOFT_CLIENT_*`, `LLM_PROVIDER`, `LLM_API_KEY`) and restart `tasker.service`.
4. **Configure GitHub Actions CD (optional)**: Set `TASKER_API_URL`, `OCI_DEPLOY_ENABLED`, `OCI_HOST`, `OCI_USER`, and `OCI_SSH_KEY` for automated Web/Android/Windows builds and deploys.

### Planned Feature Additions & Fixes
- **Gmail Integration (Multi-Account & AI Auto-Scan)**:
  - Support syncing multiple Gmail accounts.
  - Automatically scan all connected inboxes on app open and manual refresh for new task ideas.
  - Identify and ignore spam and non-task-based emails.
- **Calendar-to-Task Flow (Edit & Due-Time Picker)**:
  - Tapping an agenda item opens the suggested prep task so it can be tapped to edit before adding to the task list.
  - Add a dedicated button/tap target to edit only the due time.
  - Use a 2-part scroller wheel (numbers on the left, units like minutes/hours/days on the right) with a corner button to switch to absolute time selection.
- **Calendar Page Layout & Views**:
  - Remove the "Connected Calendars" section from the top of the Calendar page (keep accessible in Settings only).
  - Organize the agenda feed by day with collapsible/expandable dropdowns per day.
  - Add a toggle to switch between Day/Agenda, Week, and Month views.
- **[DONE in `ff0590f`, 2026-11-19] Bug Fix: Task Deletion Breaks Cloud Sync** (see [`docs/bug-diagnosis-and-fixes.md`](bug-diagnosis-and-fixes.md)):
  - **Root cause**: Investigate why `deleteTask()` + `saveTasks()` causes PocketBase sync to fail/stall and leave the UI stuck on "offline cache" even after manual sync reports complete (while undoing deletion restores sync).
  - **Solution**: Implement soft-delete (`deletedAt` tombstone) in Drift & PocketBase so deletions sync cleanly and Undo restores the task without conflict. Ensure sync errors surface clearly instead of silently falling back to "offline cache".
- **[DONE in `ff0590f`, 2026-11-19] Priority Levels Cloud Sync, Escalation Picker & Trusted Taskgivers**:
  - Add a **Save** button when editing the number of priority levels, their labels, and movement rules that pushes changes to PocketBase and reindexes all tasks (clamping out-of-range levels to the new max level).
  - Fix the syncing bug that occurs when adding more priority levels.
  - Replace the preset-only "when to move to other priority level" setting with the same 2-part scroll wheel system.
  - Ensure trusted taskgivers see the user's configured priority level count and labels both when assigning a task to the user and when viewing shared tasks from them.
- **[DONE in `ff0590f`] Sync Status Indicator**:
  - Replace the "offline cache" label at the top of the screen with a clear offline/not-syncing indicator (e.g., red text with an exclamation icon) when offline or failing to sync.
- **Bug Fix (`All` Category)**:
  - Tasks created in the `All` category must appear in all categories.

### Deferred to Phase 2 (Future)
- Two-way calendar time-blocking write-back (exporting scheduled tasks back into Google Calendar / Outlook).
- Custom domain setup (optional upgrade from `sslip.io`).
- Deeper integration with `dish-calendar-sync` if desired (both repos live side-by-side in the local `KidOBricks/` workspace).
