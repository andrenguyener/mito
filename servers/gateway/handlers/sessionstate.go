package handlers

import (
	"time"

	"github.com/andrenguyener/mito/servers/gateway/models/users"
)

type SessionState struct {
	Time time.Time
	User *users.User
}
