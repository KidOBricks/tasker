# Tasker v1 Architecture & Domain Specification (Original `/grill-me` Design)

> [!NOTE]
> **Historical Reference**: These domain mechanics (Priority Engine, Dual-Visibility In-Progress, Sequential Recurrence Catch-up, Analytics Suite, UI layouts) remain the core product specification.
> However, the **backend/sync layer** (Firebase + `web/admin.html`) was superseded on Nov 16, 2026 by the self-hosted **PocketBase + Drift** architecture in [`pocketbase-implementation-plan.md`](pocketbase-implementation-plan.md) (PR #1).

---

## 1. Definitive Design Decisions (Resolved via `/grill-me`)

| Domain | Architectural Decision | Implementation Specification |
| :--- | :--- | :--- |
| **Technology Stack** | **Flutter 3.x (Dart)** | Single codebase compiling natively to Android, Windows, Linux, and Web. |
| **Priority Engine** | **Base Priority + Computed Dynamic Priority** | Preserves user's original priority. Escalation (`L1 -> L2 -> L3`) is dynamically evaluated based on deadline proximity. Postponing a deadline automatically de-escalates the task. |
| **In-Progress Placement** | **Dual-Visibility** | Tasks marked "In Progress" appear in the top "In Progress" accordion **AND** remain visible in their parent section (L3, L2, L1, or Overdue) highlighted in active color. |
| **In-Progress Concurrency** | **Configurable Max Active Limit** | Multi-tasking permitted, with a user-configurable limit in Settings (`maxInProgressTasks`, default 3). Warning displayed when limit is reached. |
| **Overdue In-Progress** | **Dual-Listed** | An in-progress task past its due date displays in both the "In Progress" section and the top "Overdue" section with alert styling. |
| **Recurring Lifecycle** | **Archive & Spawn New Instance** | Completing an auto-scheduled task archives a permanent completed record (for historical analytics) and spawns a new task record for the next cycle. |
| **Missed Fixed Schedules** | **Sequential Cycle Catch-up** | If a fixed recurring task (e.g. "Every Wednesday") is completed late, it steps forward one cycle from the original missed date until fully caught up. |
| **Ignored Tasks** | **Skip Single Occurrence** | Marking a recurring task as "Ignored" records it as ignored in analytics and advances to the next cycle without disabling the schedule. |
| **Ideas Tab Extraction** | **AI Intelligent Extraction** | Parses email snippets, deducing clear task titles, categories, importance, and suggested deadlines. |
| **Ideas Tab Review** | **Actionable Card Feed** | Source email preview cards with 1-click `Accept`, `Edit Details`, or `Dismiss`. |
| **Calendar Tab UX** | **Hybrid Carousel + Contextual Sheet** | Top proactive feed for unlinked upcoming events + contextual bottom-sheet/panel on event tap for 1-click linked task creation. |
| **Analytics Suite** | **Comprehensive Data Viz + Export** | Stacked 4-column chart (L1, L2, L3, Overdue) + GitHub-style Activity Heatmap + 'Late-Chore' Leaderboard + Velocity Trendline + CSV/JSON data export. |
| **Desktop Layout** | **Adaptive 3-Pane / Rail Layout** | Left navigation/category rail, central task accordions, right task detail/attachment inspector. |

---

## 2. Core Data Entities

### Task Entity
- `id`, `userId`, `title` (mandatory), `description` (optional), `categoryId`
- `baseImportance` (`1..3` or `1..5`), `effectiveImportance` (computed dynamically on client)
- `dueDate`, `status` (`pending` | `in_progress` | `completed` | `ignored`), `isOverdue` (computed)
- `createdAt`, `completedAt`, `ignoredAt`, `inProgressAt`
- `attachmentUrls` / `attachments`, `recurrenceRuleId`, `calendarEventId`, `emailRef`

### Recurrence Rule Entity
- `id`, `userId`, `title`, `type` (`fixed_schedule` | `interval_after_completion`)
- `intervalDays` (for interval-based) or `schedulePattern` (`frequency`: `daily` | `weekly` | `monthly`, `daysOfWeek`, `dayOfMonth`, `timeOfDay`)
- `baseImportance`, `categoryId`, `lastMissedDueDate` (used for sequential catch-up), `nextDueAt`, `isActive`

### User Profile & Rules
- `maxInProgressTasks` (default `3`), `numImportanceLevels` (default `3`)
- `escalationThresholds` (`level2ThresholdDays`: `7`, `level3ThresholdDays`: `1`)
- `defaultDueDates` (`level3`: `tomorrow_end`, `level2`: `7_days`, `level1`: `none`)
- `twoWayTimeBlockingEnabled` (deferred to Phase 2)

---

## 3. Original Phased Feature Breakdown (Implemented in Flutter Client)
1. **Phase 1 — Core Domain Engine**: `PriorityEngine`, `RecurrenceEngine` (sequential catch-up + interval-after-completion + archive & spawn), `AnalyticsEngine`.
2. **Phase 2 — Responsive Multiplatform UI**: Adaptive mobile bottom bar & desktop navigation rail, Accordion Feed (`Overdue`, `In Progress`, `Level 3/2/1`), Add/Edit Task modal with default due date pre-population.
3. **Phase 3 — Offline Storage & Cloud Sync**: Prototype used `SharedPreferences` + Firestore REST stub; production PR #1 upgrades this to Drift SQLite + PocketBase.
4. **Phase 4 — Data Visualization & Export**: Stacked Bar Chart, time-frame toggles, Activity Heatmap, Late-Chore Leaderboard, Velocity Trendline, Category Donut, CSV/JSON export.
5. **Phase 5 — Calendar & Gmail Ideas Tabs**: Google Calendar & Outlook integration feed, prep-task generator, Gmail AI task scanner (`Accept`, `Edit`, `Dismiss`).
