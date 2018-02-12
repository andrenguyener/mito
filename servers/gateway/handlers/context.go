package handlers

import (
	"github.com/andrenguyener/mito/servers/gateway/indexes"
	"github.com/andrenguyener/mito/servers/gateway/models/users"
	"github.com/andrenguyener/mito/servers/gateway/sessions"
)

type Context struct {
	SessionKey   string
	SessionStore sessions.Store
	UserStore    users.Store
	TrieStore    *indexes.Trie
	Notifier     *Notifier
}
