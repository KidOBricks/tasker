# Tasker — Project Context & Agent Guide

> Cross-platform Flutter/Dart task manager and calendar/email orchestrator (`Windows | Android | Linux | Web`).

## Current Branch & Architecture Status
- **`main` (updated via PR #1 `ded6f6e`)**: Now holds the full production architecture (`feat/production-pocketbase-sync` merged Nov 18, 2026):
  - Go **PocketBase** backend (`backend/`) with AES-256-GCM encrypted OAuth tokens, scheduled Google Calendar / Outlook / Gmail sync, and pluggable LLM task extraction.
  - **Drift (SQLite)** offline-first sync engine (`lib/data/local/`) with outbox queue, Last-Write-Wins, and PocketBase Realtime SSE.
  - **Warm Graphite** UI redesign + self-hosted CanvasKit web shell (`web/`).
  - **OCI `sslip.io` + Caddy** deployment scripts (`deploy/`) and GitHub Actions CI/CD (`.github/workflows/ci.yml`).
  - Mocked `web/admin.html` and `AdminConsoleScreen` removed in favor of PocketBase `/_/`.

---

## Locked-In Product & Architecture Decisions
1. **Dynamic Priority Engine (`PriorityEngine`)**:
   - Tasks have a `baseImportance` (`1..3`, configurable up to 5) and a dynamically computed `effectiveImportance` based on deadline proximity. Postponing a due date de-escalates automatically.
2. **In-Progress Dual-Visibility**:
   - Tasks marked `in_progress` show in the top **In Progress** section *and* remain highlighted in their parent priority/overdue section, bounded by a configurable `maxInProgressTasks` limit (default `3`).
3. **Recurrence & Sequential Catch-up (`RecurrenceEngine`)**:
   - Supports `fixed_schedule` (calendar-based) and `interval_after_completion`.
   - Completing a task archives the completed instance for analytics and spawns the next cycle.
   - Late fixed-schedule tasks catch up sequentially one cycle at a time; "Ignore" skips a single occurrence without disabling the schedule; Vacation Mode freezes chosen routines.
4. **Production Backend & Sync (PR #1 Plan)**:
   - Single **PocketBase (Go)** binary behind **Caddy** (`sslip.io` automatic HTTPS) on an Oracle Cloud Always Free ARM64 VM, with daily backups to OCI Object Storage.
   - **Invite-only / admin-created auth** (no open self-signup; email/password + Google & Microsoft SSO; PocketBase `/_/` Admin UI exclusively).
   - **Server-side integrations**: Google Calendar (read-only), Outlook Calendar (read-only), Gmail unread scan, and pluggable LLM extraction (`gemini` | `openai_compat` | `heuristic` fallback). Two-way calendar write-back is deferred to Phase 2.
   - **Client storage**: Drift SQLite + dirty outbox queue across Web (WASM), Android, and Windows.

---

## Documentation Index
- [`docs/history-and-plan.md`](docs/history-and-plan.md) — Chronological history of work completed and next milestones.
- [`docs/pocketbase-implementation-plan.md`](docs/pocketbase-implementation-plan.md) — Current locked production architecture & execution plan (PocketBase + Drift + OCI).
- [`docs/architecture-and-roadmap.md`](docs/architecture-and-roadmap.md) — Original v1 `/grill-me` domain rules, data schemas, and UI specs (note: Firebase/admin.html parts were superseded by the PocketBase plan).
- [`docs/walkthrough-v1.md`](docs/walkthrough-v1.md) — Walkthrough of the v1 Flutter prototype on `main`.

---

## Common Commands
```bash
# Backend (Go + PocketBase)
cd backend
go test -v ./...
go run . serve --http=127.0.0.1:8090

# Frontend (Flutter + Drift)
flutter pub get
flutter analyze
flutter test
flutter run -d windows --dart-define=TASKER_API_URL=http://127.0.0.1:8090  # or chrome / android / linux
```
