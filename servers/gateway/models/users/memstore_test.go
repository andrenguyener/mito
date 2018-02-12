package users

import "testing"

func TestMemStore(t *testing.T) {
	memStore := NewMemStore()
	newUser := &NewUser{
		Email:        "test@foo.com",
		Password:     "password",
		PasswordConf: "password",
		UserName:     "username",
		FirstName:    "first",
		LastName:     "last",
	}

	user, err := memStore.Insert(newUser)

	if err != nil {
		t.Errorf("Error inserting new user %s", err)
	}

	userID := user.ID
	userCompare, err := memStore.GetByID(userID)
	if err != nil {
		t.Errorf("Error retrieving user by ID %s", err)
	}
	if userCompare.ID != userID {
		t.Errorf("Error User IDs do not match ")
	}

	userEmail := user.Email
	userCompare, err = memStore.GetByEmail(userEmail)
	if err != nil {
		t.Errorf("Error retrieving user by email %s", err)
	}

	if userCompare.Email != userEmail {
		t.Errorf("Error User Emails do not match")
	}

	userUserName := user.UserName
	userCompare, err = memStore.GetByUserName(userUserName)
	if err != nil {
		t.Errorf("Error retrieving user by username %s", err)
	}

	if userCompare.UserName != userUserName {
		t.Errorf("Error Usernames do not match")
	}

	newUpdates := &Updates{
		FirstName: "Tom",
		LastName:  "Brady",
	}

	err = memStore.Update(user.ID, newUpdates)
	if err != nil {
		t.Errorf("Error updating user by Updates %s", err)
	}
	if user.FirstName != newUpdates.FirstName || user.LastName != newUpdates.LastName {
		t.Errorf("Error names do not match updated names. Is %s %s expected %s %s", user.FirstName, user.LastName, newUpdates.FirstName, newUpdates.LastName)
	}

	err = memStore.Delete(user.ID)

	if err != nil {
		t.Errorf("Error deleting userID %s", err)
	}

	_, err = memStore.GetByID(userID)
	if err == nil {
		t.Errorf("Error, ID was not deleted")
	}

}
