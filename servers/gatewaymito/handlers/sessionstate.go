package handlers

import (
	"time"

	"github.com/mito/servers/gatewaymito/models/users"
)

type SessionState struct {
	Time time.Time
	User *users.User
}
