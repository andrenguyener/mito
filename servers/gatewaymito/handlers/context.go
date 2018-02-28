package handlers

import (
	"github.com/mito/servers/gatewaymito/indexes"
	"github.com/mito/servers/gatewaymito/models/users"
	"github.com/mito/servers/gatewaymito/sessions"
)

type Context struct {
	SessionKey   string
	SessionStore sessions.Store
	UserStore    users.Store
	TrieStore    *indexes.Trie
	Notifier     *Notifier
}
