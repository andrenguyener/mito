package indexes

import (
	"errors"

	"gopkg.in/mgo.v2/bson"
)

//ErrUserNotFound is returned when the user can't be found
var ErrUserNotFound = errors.New("user not found")

//Store represents a store for Users
type Store interface {
	Add(key string, value bson.ObjectId)
	Delete(key string, value bson.ObjectId) bool
	DFSChildren(prefix string, n int) []bson.ObjectId
}
