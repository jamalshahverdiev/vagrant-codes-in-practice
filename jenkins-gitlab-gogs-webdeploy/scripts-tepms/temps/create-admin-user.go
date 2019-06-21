// this file should be copied to:
//
//      $GOPATH/src/github.com/gogits/gogs/cmd/
//
// and should be used in:
//
//      $GOPATH/src/github.com/gogits/gogs.go

package cmd

import (
	"fmt"
	"log"

	"github.com/urfave/cli"

	"github.com/gogits/gogs/models"
	"github.com/gogits/gogs/pkg/setting"
)

var CreateAdminUser = cli.Command{
	Name:        "create-admin-user",
	Usage:       "Creates a new administrator user and dumps the user API key",
	Description: "Creates a new administrator user and dumps the user API key",
	Action:      runCreateAdminUser,
	Flags: []cli.Flag{
		stringFlag("config, c", "custom/conf/app.ini", "Custom configuration file path"),
		stringFlag("name", "", "Administrator username"),
		stringFlag("email", "", "Administrator email"),
		stringFlag("password", "", "Administrator password"),
	},
}

func runCreateAdminUser(ctx *cli.Context) error {
	if ctx.IsSet("config") {
		setting.CustomConf = ctx.String("config")
	}
	setting.NewContext()
	models.LoadConfigs()
	models.SetEngine()

	name := ctx.String("name")
	if name == "" {
		log.Fatal("You must provide the `--name` parameter value")
	}

	email := ctx.String("email")
	if email == "" {
		log.Fatal("You must provide the `--email` parameter value")
	}

	password := ctx.String("password")
	if password == "" {
		log.Fatal("You must provide the `--password` parameter value")
	}

	u := &models.User{
		Name:     name,
		Email:    email,
		Passwd:   password,
		IsAdmin:  true,
		IsActive: true,
	}

	if err := models.CreateUser(u); err != nil {
		log.Fatalf("Failed to create the user: %v", err)
	}

	t := &models.AccessToken{
		UID:  u.ID,
		Name: "api",
	}

	if err := models.NewAccessToken(t); err != nil {
		log.Fatalf("Failed to create the user API token: %v", err)
	}

	fmt.Println(t.Sha1)

	return nil
}
