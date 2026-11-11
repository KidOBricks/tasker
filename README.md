# Tasker: Next-Gen Autonomous Task & Calendar Orchestrator

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Riverpod%20v2-purple.svg)](https://riverpod.dev)
[![Cross-Platform](https://img.shields.io/badge/Platforms-Windows%20%7C%20Android%20%7C%20Linux%20%7C%20Web-success.svg)](https://flutter.dev/multi-platform)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Tasker is a cross-platform task manager and intelligent calendar orchestration engine built with Flutter and Dart. It combines dynamic priority escalation, interval- and calendar-based recurring chore engines, personal Google & Microsoft Outlook calendar syncing, Gmail inbox task extraction AI, and real-time multi-tenant cloud sync.

---

## 🚀 Key Features

### 1. Dedicated Client Apps vs. Web Admin Separation
- **Windows & Android Client Apps**: Clean, distraction-free user experience with 5 core navigation tabs:
  - 📋 **Tasks**: Categorized accordions, subtask checklists, customizable importance levels, and confetti celebration on completion.
  - 📅 **Calendar & Integrations**: Month/week calendar view with Google Calendar & Outlook integration chips, live feeds, and "+ Add Prep Task".
  - 📊 **Progress & Analytics**: Heatmaps, completion velocity, late-chore leaderboards, and CSV/JSON export.
  - 💡 **Ideas & Email Inbox AI**: Gmail scanner extracting action items directly from unread emails into draft tasks.
  - ⚙️ **Profile & Settings**: Multi-tenant cloud sync status, custom escalation windows, notifications, and Vacation Mode.
- **Enterprise Web Admin Portal (`admin.html`)**: Dedicated management dashboard for platform administrators to monitor multi-tenant users, inspect Firestore collections, promote/demote administrators, and manage account statuses.

---

### 2. Deep Calendar & Email Integrations
- **Google Calendar (REST API & OAuth 2.0)**:
  - Users link their personal Google accounts directly in the client app.
  - Synchronizes external events and meetings in real-time.
  - Generates linked **Preparation Tasks** (scheduled 2 hours prior to critical meetings) with checklist templates.
- **Microsoft Outlook Calendar (Microsoft Graph API)**:
  - Supports Microsoft 365 enterprise, work/school, and personal Outlook accounts.
  - Fetches attendees, meeting links, and calendar invites.
- **Gmail Inbox AI Task Scanner**:
  - Scans user's recent inbox threads using Gmail REST API.
  - Employs heuristic and AI regex parsing to detect action verbs, project deliverables, and explicit deadlines.
  - Populates actionable suggestions with 1-click "Accept & Add Task" or "Edit".

---

### 3. Smart Recurrence & Escalation Engines
- **Dual Recurrence Modes**:
  - **Interval-Based**: Every $X$ days, weeks, or months (with optional "After Completion" recalculation).
  - **Calendar-Based**: Google Calendar-style recurring events (e.g., "Every Tuesday & Thursday at 10:00 AM").
- **Dynamic Priority Escalation Engine**:
  - User-configurable tier depth (3, 4, or 5 levels).
  - Customizable labels per tier (e.g., Low, Medium, High, Critical, Blocker).
  - Configurable escalation windows (e.g., Escalate to Level 2 within 3 days; Escalate to Level 3 within 12 hours of due date).
  - Auto-escalates overdue tasks to maximum priority.
- **Vacation Mode**:
  - Freezes chosen recurring routines and suppresses non-critical notifications while away.
- **Task History & Undo**:
  - Reversible actions for completions, deletions, and status toggles.

---

### 4. Multi-Tenant Cloud Sync Architecture
- **Tenant Isolation**: Every user's tasks, categories, routines, and credentials are partition-stored under `/users/{userId}/...` in Cloud Firestore.
- **Local-First & Offline Support**: Changes write to local SQLite / SharedPreferences immediately and synchronize bidirectionally with Firestore when connected.
- **Multi-Device Sync**: Works seamlessly across Windows desktops, Android mobile devices, Linux, and Web browsers.

---

## 🛠️ Getting Started

### Prerequisites
- **Flutter SDK**: `>=3.19.0`
- **Dart SDK**: `>=3.3.0`
- (Optional) **Visual Studio 2022** for native Windows compilation
- (Optional) **Android Studio & SDK** for native Android APK generation

### Clone and Install
```bash
git clone https://github.com/KidOBricks/tasker.git
cd tasker
flutter pub get
```

### Run on Windows (Native Desktop)
```bash
# Ensure Windows desktop is enabled
flutter config --enable-windows-desktop

# Run native Windows debug build
flutter run -d windows
```

### Run on Android
```bash
# Ensure emulator or USB-connected device is running
flutter devices

# Run on Android
flutter run -d android
```

### Run on Web (Client App + Admin Portal)
```bash
flutter run -d chrome
```
- Open `http://localhost:<port>` for the client app.
- Open `http://localhost:<port>/admin.html` for the dedicated enterprise SaaS Web Admin Portal.

---

## 🧪 Testing & Verification

Run the full automated test suite (26 unit, recurrence, priority, auth, and widget tests):
```bash
flutter test
```

Run static code analysis:
```bash
flutter analyze
```

---

## 📁 Repository Structure
```
lib/
├── data/
│   ├── models/                # Local data entities & adapters
│   ├── repositories/          # Local task repository & caching
│   └── services/              # AuthService, DatabaseService, CalendarIntegrationService, EmailIntegrationService
├── domain/
│   ├── models/                # Core domain models (TaskItem, UserAccount, RecurrenceRule, etc.)
│   └── logic/                 # RecurrenceEngine, PriorityEngine, AnalyticsEngine
├── state/                     # Riverpod state providers (app_state, auth_state, integration_state)
├── ui/
│   ├── components/            # Reusable UI widgets (AddEditTaskDialog, TaskCard, Confetti)
│   ├── layout/                # AdaptiveScaffold (responsive navigation rail / bottom bar)
│   ├── screens/               # Tasks, Calendar, Progress, Ideas, Settings, and AdminConsole
│   └── theme/                 # Dark/light theme, typography, and color tokens
web/
├── index.html                 # Flutter Web client entry point
└── admin.html                 # Dedicated Enterprise Web Admin Portal
```

---

## 🔒 Security & Privacy
- User OAuth credentials and calendar tokens remain client-side or securely partitioned.
- Firestore security rules restrict all document access to `request.auth.uid == userId`.
- Admins cannot access private calendar tokens or personal email contents.

---

## 📄 License
Licensed under the [MIT License](LICENSE).
