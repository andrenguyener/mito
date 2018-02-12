package users

import (
	"crypto/md5"
	"encoding/hex"
	"fmt"
	"net/mail"
	"strings"

	"golang.org/x/crypto/bcrypt"
	"gopkg.in/mgo.v2/bson"
)

const gravatarBasePhotoURL = "https://www.gravatar.com/avatar/"

var bcryptCost = 13

//User represents a user account in the database
type User struct {
	ID        bson.ObjectId `json:"id" bson:"_id"`
	Email     string        `json:"email"`
	PassHash  []byte        `json:"-"` //stored, but not encoded to clients
	UserName  string        `json:"userName"`
	FirstName string        `json:"firstName"`
	LastName  string        `json:"lastName"`
	PhotoURL  string        `json:"photoURL"`
}

//Credentials represents user sign-in credentials
type Credentials struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

//NewUser represents a new user signing up for an account
type NewUser struct {
	Email        string `json:"email"`
	Password     string `json:"password"`
	PasswordConf string `json:"passwordConf"`
	UserName     string `json:"userName"`
	FirstName    string `json:"firstName"`
	LastName     string `json:"lastName"`
}

//Updates represents allowed updates to a user profile
type Updates struct {
	FirstName string `json:"firstName"`
	LastName  string `json:"lastName"`
}

//Validate validates the new user and returns an error if
//any of the validation rules fail, or nil if its valid
func (nu *NewUser) Validate() error {
	_, err := mail.ParseAddress(nu.Email)
	if err != nil {
		return fmt.Errorf("invalid email: %s", err)
	}
	if len(nu.Password) < 6 {

		return fmt.Errorf("password must be atleast 6 characters")
	}
	if strings.Compare(nu.Password, nu.PasswordConf) != 0 {

		return fmt.Errorf("passwords do not match")
	}
	if len(nu.UserName) == 0 {

		return fmt.Errorf("username must be atleast 1 character long")
	}
	return nil
}

//ToUser converts the NewUser to a User, setting the
//PhotoURL and PassHash fields appropriately
func (nu *NewUser) ToUser() (*User, error) {
	gravPhotoURL := strings.ToLower(strings.Trim(nu.Email, " "))

	hasher := md5.New()
	hasher.Write([]byte(gravPhotoURL))
	photoURL := hex.EncodeToString(hasher.Sum(nil))

	id := bson.NewObjectId()

	user := &User{
		Email:     nu.Email,
		UserName:  nu.UserName,
		FirstName: nu.FirstName,
		LastName:  nu.LastName,
		PhotoURL:  gravatarBasePhotoURL + photoURL,
		ID:        id,
	}

	err := user.SetPassword(nu.Password)
	if err != nil {
		return nil, err
	}
	return user, nil
}

//FullName returns a string of the users full name with a space in between
func (u *User) FullName() string {
	if len(u.FirstName) == 0 || len(u.LastName) == 0 {
		return u.FirstName + u.LastName
	}
	return u.FirstName + " " + u.LastName
}

//SetPassword hashes the password and stores it in the PassHash field
func (u *User) SetPassword(password string) error {
	hashPass, err := bcrypt.GenerateFromPassword([]byte(password), bcryptCost)
	if err != nil {
		return err
	}
	u.PassHash = hashPass
	return nil
}

//Authenticate compares the plaintext password against the stored hash
//and returns an error if they don't match, or nil if they do
func (u *User) Authenticate(password string) error {
	err := bcrypt.CompareHashAndPassword(u.PassHash, []byte(password))
	if err != nil {
		return err
	}
	return nil
}

//ApplyUpdates applies the updates to the user. An error
//is returned if the updates are invalid
func (u *User) ApplyUpdates(updates *Updates) error {
	if len(updates.FirstName) == 0 || len(updates.LastName) == 0 {
		return fmt.Errorf("Name must be atleast 1 character long")
	}
	u.FirstName = updates.FirstName
	u.LastName = updates.LastName
	return nil
}
