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

### Deferred to Phase 2 (Future)
- Two-way calendar time-blocking write-back (exporting scheduled tasks back into Google Calendar / Outlook).
- Custom domain setup (optional upgrade from `sslip.io`).
- Deeper integration with `dish-calendar-sync` if desired (both repos live side-by-side in the local `KidOBricks/` workspace).
