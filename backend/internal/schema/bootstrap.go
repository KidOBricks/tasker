package schema

import (
	"os"
	"strings"

	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/tools/types"
)

// EnsureSchema idempotently provisions Tasker collections, indexes, API rules,
// and OAuth2 SSO providers on PocketBase startup.
func EnsureSchema(app core.App) error {
	usersCol, err := ensureUsersCollection(app)
	if err != nil {
		return err
	}

	if err := ensureUserProfilesCollection(app, usersCol.Id); err != nil {
		return err
	}
	if err := ensureCategoriesCollection(app, usersCol.Id); err != nil {
		return err
	}
	if err := ensureRecurrenceRulesCollection(app, usersCol.Id); err != nil {
		return err
	}
	if err := ensureTasksCollection(app, usersCol.Id); err != nil {
		return err
	}
	if err := ensureOAuthConnectionsCollection(app, usersCol.Id); err != nil {
		return err
	}
	if err := ensureExternalEventsCollection(app, usersCol.Id); err != nil {
		return err
	}
	if err := ensureTaskSuggestionsCollection(app, usersCol.Id); err != nil {
		return err
	}
	if err := ensureTrustedTaskgiversCollection(app, usersCol.Id); err != nil {
		return err
	}
	return nil
}

// RegisterAuthHooks enforces invite-only OAuth2 login and suspended account blocking.
func RegisterAuthHooks(app core.App) {
	// Block OAuth2 auto-registration for unknown emails (admin-created/invited only)
	app.OnRecordAuthWithOAuth2Request("users").BindFunc(func(e *core.RecordAuthWithOAuth2RequestEvent) error {
		if e.IsNewRecord {
			return e.ForbiddenError("Account creation is restricted to invited users. Ask an administrator to create your account first.", nil)
		}
		if e.Record != nil && e.Record.GetBool("suspended") {
			return e.ForbiddenError("Your account has been suspended by an administrator.", nil)
		}
		return e.Next()
	})

	// Block suspended users on password / token auth
	app.OnRecordAuthRequest("users").BindFunc(func(e *core.RecordAuthRequestEvent) error {
		if e.Record != nil && e.Record.GetBool("suspended") {
			return e.ForbiddenError("Your account has been suspended by an administrator.", nil)
		}
		return e.Next()
	})

	app.OnRecordAuthRefreshRequest("users").BindFunc(func(e *core.RecordAuthRefreshRequestEvent) error {
		if e.Record != nil && e.Record.GetBool("suspended") {
			return e.ForbiddenError("Your account has been suspended by an administrator.", nil)
		}
		return e.Next()
	})
}

func ensureUsersCollection(app core.App) (*core.Collection, error) {
	col, err := app.FindCollectionByNameOrId("users")
	if err != nil {
		col = core.NewAuthCollection("users")
	}

	// Admin-created / invited users only: disallow public user creation
	col.CreateRule = nil
	col.DeleteRule = nil
	col.ListRule = types.Pointer("id = @request.auth.id")
	col.ViewRule = types.Pointer("id = @request.auth.id")
	col.UpdateRule = types.Pointer("id = @request.auth.id")

	ensureField(col, &core.TextField{Name: "displayName", Max: 120})
	ensureField(col, &core.SelectField{
		Name:      "role",
		Values:    []string{"user", "admin"},
		MaxSelect: 1,
	})
	ensureField(col, &core.BoolField{Name: "suspended"})

	// Configure Google / Microsoft SSO providers from env when present
	providers := []core.OAuth2ProviderConfig{}
	if id, secret := strings.TrimSpace(os.Getenv("GOOGLE_CLIENT_ID")), strings.TrimSpace(os.Getenv("GOOGLE_CLIENT_SECRET")); id != "" && secret != "" {
		providers = append(providers, core.OAuth2ProviderConfig{
			Name:         "google",
			ClientId:     id,
			ClientSecret: secret,
		})
	}
	if id, secret := strings.TrimSpace(os.Getenv("MICROSOFT_CLIENT_ID")), strings.TrimSpace(os.Getenv("MICROSOFT_CLIENT_SECRET")); id != "" && secret != "" {
		providers = append(providers, core.OAuth2ProviderConfig{
			Name:         "microsoft",
			ClientId:     id,
			ClientSecret: secret,
		})
	}
	if len(providers) > 0 {
		col.OAuth2.Enabled = true
		col.OAuth2.Providers = providers
	}

	if err := app.Save(col); err != nil {
		return nil, err
	}
	return col, nil
}

func ensureUserProfilesCollection(app core.App, usersColId string) error {
	col, err := app.FindCollectionByNameOrId("user_profiles")
	if err != nil {
		col = core.NewBaseCollection("user_profiles")
	}
	setUserOwnedRules(col)

	ensureField(col, &core.RelationField{Name: "user", CollectionId: usersColId, MaxSelect: 1, Required: true, CascadeDelete: true})
	ensureField(col, &core.TextField{Name: "displayName", Max: 120})
	ensureField(col, &core.NumberField{Name: "maxInProgressTasks"})
	ensureField(col, &core.NumberField{Name: "numImportanceLevels"})
	ensureField(col, &core.JSONField{Name: "levelNames"})
	ensureField(col, &core.NumberField{Name: "level2WindowValue"})
	ensureField(col, &core.TextField{Name: "level2WindowUnit", Max: 20})
	ensureField(col, &core.NumberField{Name: "level3WindowValue"})
	ensureField(col, &core.TextField{Name: "level3WindowUnit", Max: 20})
	ensureField(col, &core.JSONField{Name: "escalationWindows"})
	ensureField(col, &core.BoolField{Name: "twoWayTimeBlocking"})
	ensureField(col, &core.BoolField{Name: "vacationModeEnabled"})
	ensureField(col, &core.TextField{Name: "vacationStartDate", Max: 40})
	ensureField(col, &core.TextField{Name: "vacationEndDate", Max: 40})
	ensureField(col, &core.JSONField{Name: "vacationFrozenChoreIds"})
	ensureField(col, &core.TextField{Name: "vacationNotificationFilter", Max: 40})
	ensureField(col, &core.BoolField{Name: "notificationsEnabled"})
	ensureField(col, &core.NumberField{Name: "notifyPriorHours"})
	ensureField(col, &core.NumberField{Name: "notifyPriorMinutes"})
	ensureField(col, &core.TextField{Name: "notifyForTier", Max: 40})
	ensureField(col, &core.BoolField{Name: "notifyForOverdue"})
	ensureField(col, &core.BoolField{Name: "reviewTasksEnabled"})
	ensureField(col, &core.TextField{Name: "reviewTasksTime", Max: 10})
	ensureField(col, &core.BoolField{Name: "reviewTasksPersistent"})
	ensureField(col, &core.TextField{Name: "clientUpdatedAt", Max: 40})
	ensureAutodateFields(col)
	col.AddIndex("idx_user_profiles_user", true, "user", "")

	return app.Save(col)
}

func ensureCategoriesCollection(app core.App, usersColId string) error {
	col, err := app.FindCollectionByNameOrId("categories")
	if err != nil {
		col = core.NewBaseCollection("categories")
	}
	setUserOwnedRules(col)

	ensureField(col, &core.RelationField{Name: "user", CollectionId: usersColId, MaxSelect: 1, Required: true, CascadeDelete: true})
	ensureField(col, &core.TextField{Name: "clientId", Required: true, Max: 120})
	ensureField(col, &core.TextField{Name: "name", Required: true, Max: 80})
	ensureField(col, &core.NumberField{Name: "colorValue"})
	ensureField(col, &core.TextField{Name: "iconName", Max: 60})
	ensureField(col, &core.NumberField{Name: "sortOrder"})
	ensureField(col, &core.TextField{Name: "clientUpdatedAt", Max: 40})
	ensureField(col, &core.TextField{Name: "deletedAt", Max: 40})
	ensureAutodateFields(col)
	col.AddIndex("idx_categories_user_client", true, "user, clientId", "")

	return app.Save(col)
}

func ensureRecurrenceRulesCollection(app core.App, usersColId string) error {
	col, err := app.FindCollectionByNameOrId("recurrence_rules")
	if err != nil {
		col = core.NewBaseCollection("recurrence_rules")
	}
	setUserOwnedRules(col)

	ensureField(col, &core.RelationField{Name: "user", CollectionId: usersColId, MaxSelect: 1, Required: true, CascadeDelete: true})
	ensureField(col, &core.TextField{Name: "clientId", Required: true, Max: 120})
	ensureField(col, &core.TextField{Name: "title", Required: true, Max: 240})
	ensureField(col, &core.TextField{Name: "description", Max: 4000})
	ensureField(col, &core.TextField{Name: "type", Max: 40})
	ensureField(col, &core.NumberField{Name: "intervalValue"})
	ensureField(col, &core.TextField{Name: "intervalUnit", Max: 20})
	ensureField(col, &core.BoolField{Name: "afterCompletion"})
	ensureField(col, &core.TextField{Name: "frequency", Max: 20})
	ensureField(col, &core.JSONField{Name: "daysOfWeek"})
	ensureField(col, &core.NumberField{Name: "dayOfMonth"})
	ensureField(col, &core.TextField{Name: "timeOfDay", Max: 10})
	ensureField(col, &core.NumberField{Name: "baseImportance"})
	ensureField(col, &core.TextField{Name: "categoryId", Max: 120})
	ensureField(col, &core.TextField{Name: "lastMissedDueDate", Max: 40})
	ensureField(col, &core.TextField{Name: "nextDueAt", Max: 40})
	ensureField(col, &core.BoolField{Name: "isActive"})
	ensureField(col, &core.TextField{Name: "clientCreatedAt", Max: 40})
	ensureField(col, &core.TextField{Name: "clientUpdatedAt", Max: 40})
	ensureField(col, &core.TextField{Name: "deletedAt", Max: 40})
	ensureAutodateFields(col)
	col.AddIndex("idx_rules_user_client", true, "user, clientId", "")

	return app.Save(col)
}

func ensureTasksCollection(app core.App, usersColId string) error {
	col, err := app.FindCollectionByNameOrId("tasks")
	if err != nil {
		col = core.NewBaseCollection("tasks")
	}
	setUserOwnedRules(col)

	ensureField(col, &core.RelationField{Name: "user", CollectionId: usersColId, MaxSelect: 1, Required: true, CascadeDelete: true})
	ensureField(col, &core.TextField{Name: "clientId", Required: true, Max: 120})
	ensureField(col, &core.TextField{Name: "title", Required: true, Max: 300})
	ensureField(col, &core.TextField{Name: "description", Max: 8000})
	ensureField(col, &core.TextField{Name: "categoryId", Max: 120})
	ensureField(col, &core.NumberField{Name: "baseImportance"})
	ensureField(col, &core.NumberField{Name: "effectiveImportance"})
	ensureField(col, &core.TextField{Name: "dueDate", Max: 40})
	ensureField(col, &core.TextField{Name: "status", Max: 30})
	ensureField(col, &core.BoolField{Name: "isOverdue"})
	ensureField(col, &core.TextField{Name: "clientCreatedAt", Max: 40})
	ensureField(col, &core.TextField{Name: "completedAt", Max: 40})
	ensureField(col, &core.TextField{Name: "ignoredAt", Max: 40})
	ensureField(col, &core.TextField{Name: "inProgressAt", Max: 40})
	ensureField(col, &core.JSONField{Name: "attachmentPaths"})
	ensureField(col, &core.FileField{Name: "attachments", MaxSelect: 10, MaxSize: 10 * 1024 * 1024, Protected: true})
	ensureField(col, &core.TextField{Name: "recurrenceRuleId", Max: 120})
	ensureField(col, &core.TextField{Name: "calendarEventId", Max: 240})
	ensureField(col, &core.JSONField{Name: "emailRef"})
	ensureField(col, &core.JSONField{Name: "subtasks"})
	ensureField(col, &core.TextField{Name: "givenById", Max: 120})
	ensureField(col, &core.TextField{Name: "givenByName", Max: 120})
	ensureField(col, &core.TextField{Name: "clientUpdatedAt", Max: 40})
	ensureField(col, &core.TextField{Name: "deletedAt", Max: 40})
	ensureAutodateFields(col)
	col.AddIndex("idx_tasks_user_client", true, "user, clientId", "")

	return app.Save(col)
}

func ensureOAuthConnectionsCollection(app core.App, usersColId string) error {
	col, err := app.FindCollectionByNameOrId("oauth_connections")
	if err != nil {
		col = core.NewBaseCollection("oauth_connections")
	}
	// Strictly server-side / superuser-only: tokens never exposed to client CRUD
	col.ListRule = nil
	col.ViewRule = nil
	col.CreateRule = nil
	col.UpdateRule = nil
	col.DeleteRule = nil

	ensureField(col, &core.RelationField{Name: "user", CollectionId: usersColId, MaxSelect: 1, Required: true, CascadeDelete: true})
	ensureField(col, &core.TextField{Name: "provider", Required: true, Max: 30})
	ensureField(col, &core.TextField{Name: "accountEmail", Max: 200})
	ensureField(col, &core.TextField{Name: "displayName", Max: 120})
	ensureField(col, &core.TextField{Name: "encryptedAccessToken", Max: 8192})
	ensureField(col, &core.TextField{Name: "encryptedRefreshToken", Max: 8192})
	ensureField(col, &core.TextField{Name: "expiresAt", Max: 40})
	ensureField(col, &core.TextField{Name: "scopes", Max: 500})
	ensureField(col, &core.JSONField{Name: "selectedCalendarIds"})
	ensureField(col, &core.TextField{Name: "lastSyncedAt", Max: 40})
	ensureAutodateFields(col)
	col.AddIndex("idx_oauth_user_provider", true, "user, provider", "")

	return app.Save(col)
}

func ensureExternalEventsCollection(app core.App, usersColId string) error {
	col, err := app.FindCollectionByNameOrId("external_events")
	if err != nil {
		col = core.NewBaseCollection("external_events")
	}
	col.ListRule = types.Pointer("user = @request.auth.id")
	col.ViewRule = types.Pointer("user = @request.auth.id")
	col.UpdateRule = types.Pointer("user = @request.auth.id")
	col.CreateRule = nil
	col.DeleteRule = nil

	ensureField(col, &core.RelationField{Name: "user", CollectionId: usersColId, MaxSelect: 1, Required: true, CascadeDelete: true})
	ensureField(col, &core.TextField{Name: "externalId", Required: true, Max: 240})
	ensureField(col, &core.TextField{Name: "source", Required: true, Max: 30})
	ensureField(col, &core.TextField{Name: "calendarId", Max: 240})
	ensureField(col, &core.TextField{Name: "calendarName", Max: 200})
	ensureField(col, &core.TextField{Name: "title", Max: 300})
	ensureField(col, &core.TextField{Name: "startTime", Max: 40})
	ensureField(col, &core.TextField{Name: "endTime", Max: 40})
	ensureField(col, &core.TextField{Name: "location", Max: 300})
	ensureField(col, &core.TextField{Name: "description", Max: 4000})
	ensureField(col, &core.TextField{Name: "meetingUrl", Max: 500})
	ensureField(col, &core.JSONField{Name: "attendees"})
	ensureField(col, &core.BoolField{Name: "hasLinkedTask"})
	ensureField(col, &core.TextField{Name: "deletedAt", Max: 40})
	ensureAutodateFields(col)
	col.AddIndex("idx_ext_events_user_src_id", true, "user, source, externalId", "")

	return app.Save(col)
}

func ensureTaskSuggestionsCollection(app core.App, usersColId string) error {
	col, err := app.FindCollectionByNameOrId("task_suggestions")
	if err != nil {
		col = core.NewBaseCollection("task_suggestions")
	}
	col.ListRule = types.Pointer("user = @request.auth.id")
	col.ViewRule = types.Pointer("user = @request.auth.id")
	col.UpdateRule = types.Pointer("user = @request.auth.id")
	col.DeleteRule = types.Pointer("user = @request.auth.id")
	col.CreateRule = nil

	ensureField(col, &core.RelationField{Name: "user", CollectionId: usersColId, MaxSelect: 1, Required: true, CascadeDelete: true})
	ensureField(col, &core.TextField{Name: "emailId", Required: true, Max: 240})
	ensureField(col, &core.TextField{Name: "sender", Max: 240})
	ensureField(col, &core.TextField{Name: "subject", Max: 400})
	ensureField(col, &core.TextField{Name: "snippet", Max: 4000})
	ensureField(col, &core.TextField{Name: "receivedAt", Max: 40})
	ensureField(col, &core.TextField{Name: "title", Max: 300})
	ensureField(col, &core.TextField{Name: "description", Max: 4000})
	ensureField(col, &core.TextField{Name: "categoryId", Max: 120})
	ensureField(col, &core.NumberField{Name: "importance"})
	ensureField(col, &core.TextField{Name: "suggestedDueDate", Max: 40})
	ensureField(col, &core.TextField{Name: "status", Max: 30})
	ensureAutodateFields(col)
	col.AddIndex("idx_suggestions_user_email", true, "user, emailId", "")

	return app.Save(col)
}

func ensureTrustedTaskgiversCollection(app core.App, usersColId string) error {
	col, err := app.FindCollectionByNameOrId("trusted_taskgivers")
	if err != nil {
		col = core.NewBaseCollection("trusted_taskgivers")
	}
	setUserOwnedRules(col)

	ensureField(col, &core.RelationField{Name: "user", CollectionId: usersColId, MaxSelect: 1, Required: true, CascadeDelete: true})
	ensureField(col, &core.TextField{Name: "name", Required: true, Max: 120})
	ensureField(col, &core.EmailField{Name: "email"})
	ensureField(col, &core.TextField{Name: "token", Required: true, Max: 120})
	ensureField(col, &core.BoolField{Name: "isActive"})
	ensureAutodateFields(col)
	col.AddIndex("idx_taskgivers_token", true, "token", "")
	col.AddIndex("idx_taskgivers_user", false, "user", "")

	return app.Save(col)
}

func setUserOwnedRules(col *core.Collection) {
	own := "user = @request.auth.id"
	col.ListRule = types.Pointer(own)
	col.ViewRule = types.Pointer(own)
	col.CreateRule = types.Pointer("@request.auth.id != \"\" && @request.body.user = @request.auth.id")
	col.UpdateRule = types.Pointer(own)
	col.DeleteRule = types.Pointer(own)
}

func ensureField(col *core.Collection, f core.Field) {
	if col.Fields.GetByName(f.GetName()) == nil {
		col.Fields.Add(f)
	}
}

func ensureAutodateFields(col *core.Collection) {
	ensureField(col, &core.AutodateField{Name: "created", OnCreate: true})
	ensureField(col, &core.AutodateField{Name: "updated", OnCreate: true, OnUpdate: true})
}
