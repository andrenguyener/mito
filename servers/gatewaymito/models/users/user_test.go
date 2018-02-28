package users

import (
	"testing"

	"golang.org/x/crypto/bcrypt"
)

//TODO: add tests for the various functions in user.go, as described in the assignment.
//use `go test -cover` to ensure that you are covering all or nearly all of your code paths.



func TestValidate(t *testing.T) {

	cases := []struct {
		name          string
		user          *NewUser
		expectedError bool
	}{
		{
			"All valid",
			&NewUser{
				Email:        "test@foo.com",
				Password:     "password",
				PasswordConf: "password",
				UserName:     "username",
				FirstName:    "firstname",
				LastName:     "lastname",
			},
			false,
		},
		{
			"Invalid email",
			&NewUser{
				Email:        "test",
				Password:     "password",
				PasswordConf: "password",
				UserName:     "username",
				FirstName:    "firstname",
				LastName:     "lastname",
			},
			true,
		},
		{
			"Invalid Password macth",
			&NewUser{
				Email:        "test@foo.com",
				Password:     "passworddoesnotmatch",
				PasswordConf: "password",
				UserName:     "username",
				FirstName:    "firstname",
				LastName:     "lastname",
			},
			true,
		},
		{
			"Invalid Username",
			&NewUser{
				Email:        "test@foo.com",
				Password:     "password",
				PasswordConf: "password",
				UserName:     "",
				FirstName:    "firstname",
				LastName:     "lastname",
			},
			true,
		},
	}

	for _, c := range cases {
		err := c.user.Validate()
		errFlag := false
		if err != nil {
			errFlag = true
		}
		if errFlag != c.expectedError {

			t.Errorf("%s: got %v but expected %v. Error was: %s", c.name, errFlag, c.expectedError, err)

		}
	}

}

func TestToUser(t *testing.T) {
	cases := []struct {
		name             string
		user             *NewUser
		expectedPhotoURL string
		expectedError    bool
	}{
		{
			"Valid PhotoURL",
			&NewUser{
				Email:        "myemailaddress@example.com",
				Password:     "password",
				PasswordConf: "password",
				UserName:     "username",
				FirstName:    "firstname",
				LastName:     "lastname",
			},
			gravatarBasePhotoURL + "0bc83cb571cd1c50ba6f3e8a78ef1346",
			false,
		},
		{
			"Invalid PhotoURL",
			&NewUser{
				Email:        "myemailaddressfail@example.com",
				Password:     "password",
				PasswordConf: "password",
				UserName:     "username",
				FirstName:    "firstname",
				LastName:     "lastname",
			},
			gravatarBasePhotoURL + "0bc83cb571cd1c50ba6f3e8a78ef1346",
			true,
		},
		{
			"PhotoURL Uppercased",
			&NewUser{
				Email:        "MyEmailAddress@example.com",
				Password:     "password",
				PasswordConf: "password",
				UserName:     "username",
				FirstName:    "firstname",
				LastName:     "lastname",
			},
			gravatarBasePhotoURL + "0bc83cb571cd1c50ba6f3e8a78ef1346",
			false,
		},
		{
			"PhotoURL spaces",
			&NewUser{
				Email:        "myemailaddress@example.com   ",
				Password:     "password",
				PasswordConf: "password",
				UserName:     "username",
				FirstName:    "firstname",
				LastName:     "lastname",
			},
			gravatarBasePhotoURL + "0bc83cb571cd1c50ba6f3e8a78ef1346",
			false,
		},
	}
	for _, c := range cases {
		user, err := c.user.ToUser()

		if err != nil {
			t.Errorf("Error converting newuser to user: %s", err)
		}
		if user.PhotoURL != c.expectedPhotoURL && c.expectedError != true {
			t.Errorf("%s: got %v but expected %v.", c.name, user.PhotoURL, c.expectedPhotoURL)
		}
		err = bcrypt.CompareHashAndPassword(user.PassHash, []byte(c.user.Password))
		if err != nil {
			t.Errorf("%s: password hash does not equate to original password", c.name)
		}
		if user.Email != c.user.Email {
			t.Errorf("%s: got %v but expected %v.", c.name, user.Email, c.user.Email)
		}

	}
}

func TestFullName(t *testing.T) {
	cases := []struct {
		name         string
		user         *User
		expectedName string
	}{
		{
			"Valid Name",
			&User{
				FirstName: "first",
				LastName:  "last",
			},
			"first last",
		},
		{
			"No first name",
			&User{
				FirstName: "",
				LastName:  "last",
			},
			"last",
		},
		{
			"No last name",
			&User{
				FirstName: "",
				LastName:  "last",
			},
			"last",
		},
		{
			"No names",
			&User{
				FirstName: "",
				LastName:  "",
			},
			"",
		},
	}
	for _, c := range cases {
		if c.user.FullName() != c.expectedName {
			t.Errorf("%s: got %v but expected %v.", c.name, c.user.FullName(), c.expectedName)
		}
	}

}

func TestAuthenticate(t *testing.T) {
	cases := []struct {
		name           string
		user           *User
		inputPass      string
		comparePass    string
		expectedOutput bool
	}{
		{
			"Valid Password",
			&User{},
			"password",
			"password",
			true,
		},
		{
			"Invalid Password",
			&User{},
			"incorrectPassword",
			"password",
			false,
		},
	}

	for _, c := range cases {
		c.user.SetPassword(c.inputPass)
		err := c.user.Authenticate(c.comparePass)
		if err != nil && c.expectedOutput == true {
			t.Errorf("%s: Passwords were valid but got an error: %s", c.name, err)
		}
		if err == nil && c.expectedOutput != true {
			t.Errorf("%s: Passwords were not valid and expected an error", c.name)
		}
	}
}

func TestApplyUpdates(t *testing.T) {
	cases := []struct {
		name           string
		user           *User
		updates        *Updates
		expectedOutput bool
	}{
		{
			"Valid update",
			&User{},
			&Updates{
				FirstName: "Tom",
				LastName:  "Brady",
			},
			true,
		},
		{
			"Invalid update no first name",
			&User{},
			&Updates{
				FirstName: "",
				LastName:  "Brady",
			},
			false,
		},
		{
			"Invalid update no last name",
			&User{},
			&Updates{
				FirstName: "Tom",
				LastName:  "",
			},
			false,
		},
	}

	for _, c := range cases {
		err := c.user.ApplyUpdates(c.updates)
		if err != nil && c.expectedOutput != false {
			t.Errorf("%s: Updates were valid but got an error: %s", c.name, err)
		}
		if err == nil && c.expectedOutput == false {
			t.Errorf("%s: Updates were not valid and expected an error", c.name)
		}
		if c.expectedOutput == true {
			if c.user.FirstName != c.updates.FirstName {
				t.Errorf("%s: Updates were valid but did not match to User. Expected First Name %s but got %s", c.name, c.updates.FirstName, c.user.FirstName)
			}
			if c.user.LastName != c.updates.LastName {
				t.Errorf("%s: Updates were valid but did not match to User. Expected Last Name %s, but got %s", c.name, c.updates.LastName, c.user.LastName)
			}
		}

	}
}
