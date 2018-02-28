package users

import (
	"fmt"
	"os"
	"testing"

	mgo "gopkg.in/mgo.v2"
)

func TestMongoStore(t *testing.T) {
	mongoAddr := os.Getenv("MONGOADDR")

	if len(mongoAddr) == 0 {
		mongoAddr = "localhost:27017"
	}

	sess, err := mgo.Dial(mongoAddr)
	if err != nil {
		fmt.Printf("error dialing mongo: %v\n", err)
	}

	store := NewMongoStore(sess, "mongotest", "users")
	newUser := &NewUser{
		Email:        "test@foo.com",
		Password:     "password",
		PasswordConf: "password",
		UserName:     "username",
		FirstName:    "first",
		LastName:     "last",
	}

	user, err := store.Insert(newUser)
	if err != nil {
		t.Errorf("Error inserting new user %s", err)
	}

	userID := user.ID
	userCompare, err := store.GetByID(userID)
	if err != nil {
		t.Errorf("Error retrieving user by User ID %s", err)
	}
	if userCompare.ID != userID {
		t.Errorf("Error User IDs do not match got %s expected %s", userCompare.ID, userID)
	}

	userEmail := user.Email
	userCompare, err = store.GetByEmail(userEmail)
	if err != nil {
		t.Errorf("Error retrieving user by email %s", err)
	}
	if userCompare.Email != userEmail {
		t.Errorf("Error User Emails do not match got %s expected %s", userCompare.Email, userEmail)
	}

	userUserName := user.UserName
	userCompare, err = store.GetByUserName(userUserName)
	if err != nil {
		t.Errorf("Error retrieving user by User Name %s", err)
	}
	if userCompare.UserName != userUserName {
		t.Errorf("Error User Names do not match got %s expected %s", userCompare.UserName, userUserName)
	}

	newUpdates := &Updates{
		FirstName: "Tom",
		LastName:  "Brady",
	}

	err = store.Update(user.ID, newUpdates)
	if err != nil {
		t.Errorf("Error updating user by Updates %s", err)
	}
	updatedUser, err := store.GetByID(user.ID)
	if err != nil {
		t.Errorf("Error updating user by Updates %s", err)
	}
	if updatedUser.FirstName != newUpdates.FirstName || updatedUser.LastName != newUpdates.LastName {
		t.Errorf("Error names do not match updated names. Is %s %s expected %s %s", user.FirstName, user.LastName, newUpdates.FirstName, newUpdates.LastName)
	}

	err = store.Delete(user.ID)

	if err != nil {
		t.Errorf("Error deleting userID %s", err)
	}

	_, err = store.GetByID(userID)
	if err == nil {
		t.Errorf("Error, ID was not deleted")
	}
}
