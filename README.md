# Tasker: Task & Calendar Sync

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![Go Backend](https://img.shields.io/badge/Backend-PocketBase%20%28Go%29-00ADD8.svg)](https://pocketbase.io)
[![Cross-Platform](https://img.shields.io/badge/Platforms-Web%20%7C%20Android%20%7C%20Windows-success.svg)](https://flutter.dev/multi-platform)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Tasker is a cross-platform task manager and calendar orchestrator built with **Flutter + Drift (SQLite)** on the client and a custom **Go PocketBase** backend running behind **Caddy** on an Oracle Cloud Always Free VM (`sslip.io` HTTPS).

---

## Key Features

### 1. Offline-First Cross-Device Sync
- **Drift SQLite Local Storage**: Works offline across Web (WASM via `sqlite3.wasm` + `drift_worker.js`), Android, and Windows with per-user tenant isolation (`userId`), `SyncOutbox` offline queueing, and soft deletes (`deletedAt`).
- **PocketBase Realtime + Last-Write-Wins**: Bidirectional sync on startup, app resume, and live Server-Sent Events (SSE) subscriptions across all signed-in devices.
- **5 Clean User Tabs**: Tasks, Calendar, Progress & Analytics, Ideas & Email Inbox AI, and Profile & Settings.
- **Built-in Admin UI (`/_/`):** User provisioning, password resets, account suspension, and database inspection are handled directly in PocketBase's `/_/` Admin UI.

### 2. Invite-Only Authentication & OAuth2 SSO
- Open self-signup is disabled; accounts are created/invited by an administrator in PocketBase `/_/`.
- Supports email/password sign-in plus Google and Microsoft OAuth2 SSO (for matching invited users).
- Suspended accounts are blocked at login and session refresh.

### 3. Server-Side Calendar, Gmail & AI Task Extraction
- **OAuth2 Authorization Code Flow**: Clients open the PocketBase server's signed-state `/api/integrations/{provider}/start` flow; OAuth refresh tokens are encrypted at rest with **AES-256-GCM** in PocketBase (`oauth_connections`, hidden from client API rules).
- **Google Calendar & Microsoft Outlook**: Read-only background sync every 15 minutes (and on-demand via `POST /api/integrations/sync`) pulls upcoming meetings so you can link 1-click preparation tasks.
- **Gmail Inbox AI**: Scans unread inbox messages server-side through a pluggable `ExtractorProvider` (`gemini`, any OpenAI-compatible free endpoint like Groq/OpenRouter, or heuristic keyword fallback) and writes pending `task_suggestions`.

### 4. Smart Recurrence & Priority Escalation
- **Dual Recurrence Modes**: Interval-based (with optional after-completion recalculation) and calendar-based schedules (daily/weekly/monthly/yearly).
- **Dynamic Priority Escalation**: User-configurable importance tiers, custom labels, escalation windows before due dates, overdue auto-escalation, and Vacation Mode chore freezing.

---

## Deploying to Oracle Cloud (Always Free + `sslip.io`)

### Prerequisites on OCI
1. Provision an Ubuntu 22.04/24.04 ARM64 (`VM.Standard.A1.Flex`) instance.
2. In the OCI **VCN Security List**, open inbound **TCP 80** and **TCP 443** (`0.0.0.0/0`).

### One-Command Server Bootstrap
```bash
git clone https://github.com/KidOBricks/tasker.git
cd tasker
sudo bash deploy/oci-setup.sh --ip <YOUR_OCI_PUBLIC_IP>
```
This installs Caddy (automatic Let's Encrypt HTTPS for `https://<dashed-ip>.sslip.io`), builds/installs the `tasker-server` Go binary, creates `/opt/tasker/.env` with a fresh AES-256-GCM `TOKEN_ENCRYPTION_KEY`, and enables `tasker.service`.

Then:
1. Edit `/opt/tasker/.env` with your `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `MICROSOFT_CLIENT_ID`, `MICROSOFT_CLIENT_SECRET`, and `LLM_API_KEY` (`LLM_PROVIDER=gemini` or `openai`), then run:
   ```bash
   sudo systemctl restart tasker
   ```
2. Register these OAuth Redirect URIs in Google Cloud Console & Microsoft Entra ID:
   - Google:
     - `https://<dashed-ip>.sslip.io/api/integrations/google/callback`
     - `https://<dashed-ip>.sslip.io/api/oauth2-redirect`
   - Microsoft:
     - `https://<dashed-ip>.sslip.io/api/integrations/microsoft/callback`
     - `https://<dashed-ip>.sslip.io/api/oauth2-redirect`
3. Visit `https://<dashed-ip>.sslip.io/_/` to create your PocketBase superuser, configure Google/Microsoft under Settings -> Auth providers (optional if using SSO login), and create user accounts.

### Automated Builds & Deployments (GitHub Actions)
[`.github/workflows/ci.yml`](.github/workflows/ci.yml) runs `go test`, builds the `linux/arm64` server binary, runs `flutter analyze` + `flutter test`, and builds **Web**, **Android APK**, and **Windows** artifacts.
- Set repository variable `TASKER_API_URL=https://<dashed-ip>.sslip.io` so mobile/desktop release builds connect automatically.
- To enable automatic SSH deployment to OCI on pushes to `main`, set repository variable `OCI_DEPLOY_ENABLED=true` and repository secrets `OCI_HOST`, `OCI_USER`, and `OCI_SSH_KEY`.

---

## Local Development & Verification

### Backend (Go + PocketBase)
```bash
cd backend
go test -v ./...
go run . serve --http=127.0.0.1:8090
```

### Frontend (Flutter + Drift)
```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --dart-define=TASKER_API_URL=http://127.0.0.1:8090
```

If you modify Drift tables in `lib/data/local/app_database.dart`, regenerate `app_database.g.dart` with:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Repository Structure
```text
backend/                   # Custom PocketBase Go server, schema bootstrap, AES crypto, OAuth/Calendar/Gmail sync & LLM extractor
deploy/                    # OCI setup script, systemd unit, Caddyfile template, .env.example
.github/workflows/ci.yml   # Go + Flutter CI, Web/APK/Windows artifacts & optional OCI SSH CD
lib/
├── data/
│   ├── local/             # Drift SQLite tables & generated database
│   ├── repositories/      # Tenant-isolated repository & SyncOutbox queueing
│   └── services/          # ServerConfig, PocketBase client, AuthService, DatabaseService, Calendar & Email services
├── domain/                # Models (TaskItem, UserAccount, RecurrenceRule, UserProfile) & Priority/Recurrence/Analytics engines
├── state/                 # Riverpod providers (auth_state, app_state, integration_state)
└── ui/                    # AdaptiveScaffold, Auth, Home, Calendar, Progress, Ideas & Settings screens
```

---

## License
Licensed under the [MIT License](LICENSE).

