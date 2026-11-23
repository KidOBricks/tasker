# STATE (handoff)
Updated: 2026-11-23. Read `AGENTS.md`, `tasker/AGENTS.md`, `tasker/docs/history-and-plan.md` first.

## Current Goal
Finish and deploy **tasker** (Flutter + self-hosted PocketBase/Drift). Keep **dish-calendar-sync** (DISH shifts -> Google Calendar/.ics) running as is.

## Key Decisions & Constraints
- Stack: Flutter client with Drift offline sync. Go PocketBase backend in `tasker/backend/`. Deployed on an OCI Always Free ARM VM behind Caddy and sslip.io. PR #1 is merged into `main`.
- Design: Warm Graphite UI. Dynamic priority escalation. Soft-delete tombstones for sync (`docs/bug-diagnosis-and-fixes.md`).
- Last tasker commit `ff0590f` (19 Nov, branch `main`) fixed delete sync, the priority reindex/wheel, and taskgiver priority levels. It was not manually re-verified after that commit.
- Notifications (closed-app Android alarms, Windows tray) landed 18 Nov.
- Secrets live in `/opt/tasker/.env` and local `.env`. Never commit them.
- The workspace root is not a git repo. `tasker/` and `dish-calendar-sync/` are separate repos.

## Files Modified
- This session: only this `STATE.md` (created).
- Recent tasker work: `lib/ui/screens/settings/settings_screen.dart`, `lib/domain/models/user_profile.dart`, `lib/state/app_state.dart`, `lib/data/services/database_service.dart`, `backend/internal/integrations/taskgivers.go`.
- The tasker git tree was clean as of 23 Nov.

## Verified vs. Open (code grep only; tests not run)
- Done in `ff0590f`: delete-sync fix, `SyncStatus.error` and red warning in `adaptive_scaffold.dart`, `DurationWheelDialog` (`lib/ui/widgets/duration_wheel_picker.dart`), priority Save and reindex, taskgiver levels. `history-and-plan.md` still lists these as open, so update it.
- Open, no code found:
  - Gmail multi-account and spam filtering
  - Calendar page: day-grouped agenda and Day/Week/Month toggle
  - `All` category fix, unconfirmed
- Not confirmed: calendar-to-task edit and due-time picker; the "Connected Calendars" section is gone from `lib`, so that may be done.

## Immediate Next Step
Run `flutter analyze` and `flutter test` in `tasker/`, then `go test ./...` in `tasker/backend`. Then build the Calendar day-grouped agenda and Day/Week/Month toggle.
