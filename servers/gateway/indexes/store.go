package indexes

import (
	"errors"
)

//ErrUserNotFound is returned when the user can't be found
var ErrUserNotFound = errors.New("user not found")

//Store represents a store for Users
type Store interface {
	Add(key string, value int)
	Delete(key string, value int) bool
	DFSChildren(prefix string, n int) []int
}
