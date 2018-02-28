package handlers

import (
	"github.com/andrenguyener/mito/servers/gatewaymito/indexes"
	"github.com/andrenguyener/mito/servers/gatewaymito/models/users"
	"github.com/andrenguyener/mito/servers/gatewaymito/sessions"
)

type Context struct {
	SessionKey   string
	SessionStore sessions.Store
	UserStore    users.Store
	TrieStore    *indexes.Trie
	Notifier     *Notifier
}
