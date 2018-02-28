package users

import (
	"fmt"
)

//MemStore slice pf Users
type MemStore struct {
	entries []*User
}

//NewMemStore initialize and returns Users slice
func NewMemStore() *MemStore {
	return &MemStore{
		entries: []*User{},
	}
}

//GetByID returns the User with the given ID
func (ms *MemStore) GetByID(id int) (*User, error) {
	for _, user := range ms.entries {
		if user.UserId == id {
			return user, nil
		}
	}
	return nil, ErrUserNotFound
}

//GetByEmail returns the User with the given email
func (ms *MemStore) GetByEmail(email string) (*User, error) {
	for _, user := range ms.entries {
		if user.UserEmail == email {
			return user, nil
		}
	}
	return nil, ErrUserNotFound
}

//GetByUserName returns the User with the given Username
func (ms *MemStore) GetByUserName(username string) (*User, error) {
	for _, user := range ms.entries {
		if user.Username == username {
			return user, nil
		}
	}
	return nil, ErrUserNotFound
}

//Insert converts the NewUser to a User, inserts
//it into the database, and returns it
func (ms *MemStore) Insert(newUser *NewUser) (*User, error) {
	err := newUser.Validate()
	if err != nil {
		return nil, fmt.Errorf("Error validating user %s", err)
	}
	newPotentialUser, err := newUser.ToUser()
	if err != nil {
		return nil, fmt.Errorf("Error converting to user %s", err)
	}
	ms.entries = append(ms.entries, newPotentialUser)
	return newPotentialUser, nil
}

//Update applies UserUpdates to the given user ID
func (ms *MemStore) Update(userID int, updates *Updates) error {
	userUpdate, err := ms.GetByID(userID)
	if err != nil {
		return fmt.Errorf("Error getting User by ID %s", err)
	}
	err = userUpdate.ApplyUpdates(updates)
	if err != nil {
		return fmt.Errorf("Error applying update to User ID %s", err)
	}
	return nil
}

//Delete deletes the user with the given ID
func (ms *MemStore) Delete(userID int) error {
	for index, user := range ms.entries {
		if user.UserId == userID {
			ms.entries = append(ms.entries[:index], ms.entries[index+1:]...)
			return nil
		}
	}
	return fmt.Errorf("Error deleting user")
}
