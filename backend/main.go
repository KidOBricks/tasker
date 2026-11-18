package main

import (
	"log"
	"os"

	"github.com/KidOBricks/tasker/backend/internal/integrations"
	"github.com/KidOBricks/tasker/backend/internal/schema"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
)

func main() {
	app := pocketbase.New()

	schema.RegisterAuthHooks(app)

	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		if err := schema.EnsureSchema(app); err != nil {
			return err
		}

		svc, err := integrations.NewServiceFromEnv(app)
		if err != nil {
			return err
		}
		svc.RegisterRoutes(se)
		svc.RegisterCron()

		// Optional local static fallback if pb_public exists
		if info, err := os.Stat("pb_public"); err == nil && info.IsDir() {
			se.Router.GET("/{path...}", apis.Static(os.DirFS("pb_public"), true))
		}

		return se.Next()
	})

	if err := app.Start(); err != nil {
		log.Fatal(err)
	}
}
