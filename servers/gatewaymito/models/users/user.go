package users

import (
	"crypto/md5"
	"fmt"
	"net/mail"
	"strings"

	"golang.org/x/crypto/bcrypt"
)

const gravatarBasePhotoURL = "https://www.gravatar.com/avatar/"

var bcryptCost = 13

//User represents a user account in the database
type User struct {
	UserId             int    `json:"userId"`
	UserEmail          string `json:"userEmail"`
	PasswordHash       []byte `json:"-"` //stored, but not encoded to clients
	Username           string `json:"username"`
	UserFname          string `json:"userFname"`
	UserLname          string `json:"userLname"`
	UserDOB            string `json:"userDOB"`
	PhotoUrl           string `json:"photoURL"`
	NumFriends         int    `json:"NumFriends"`
	IsDelete           bool   `json:"isDelete"`
	ProfileImageId     int    `json:"profileImageId"`
	ProfileImage       []byte `json:"-"`
	ProfileImageString string `json:"profileImageString"`
	EbayToken          string `json:"ebayToken"`
}

//Credentials represents user sign-in credentials
type Credentials struct {
	Usercred string `json:"usercred"`
	Password string `json:"password"`
}

//NewUser represents a new user signing up for an account
type NewUser struct {
	UserEmail        string `json:"userEmail"`
	UserPassword     string `json:"password"`
	UserPasswordConf string `json:"passwordConf"`
	Username         string `json:"username"`
	UserFname        string `json:"userFname"`
	UserLname        string `json:"userLname"`
	UserDOB          string `json:"userDOB"`
}

//Updates represents allowed updates to a user profile
type Updates struct {
	UserFname string `json:"userFname"`
	UserLname string `json:"userLname"`
}

//PasswordUpdate represents allowed password updates to a user profile
type PasswordUpdate struct {
	UserPassword        string `json:"password"`
	UserNewPassword     string `json:"passwordNew"`
	UserNewPasswordConf string `json:"passwordNewConf"`
}

//PersonalUpdate represents allowed updates to a user profile
type PersonalUpdate struct {
	UserFname string `json:"userFname"`
	UserLname string `json:"userLname"`
	UserDOB   string `json:"userDOB"`
	UserEmail string `json:"userEmail"`
	Username  string `json:"username"`
	PhotoUrl  string `json:"photoURL"`
}

//Validate validates the new user and returns an error if
//any of the validation rules fail, or nil if its valid
func (nu *NewUser) Validate() error {
	_, err := mail.ParseAddress(nu.UserEmail)
	if err != nil {
		return fmt.Errorf("invalid email: %s", err)
	}
	if len(nu.UserPassword) < 6 {

		return fmt.Errorf("password must be atleast 6 characters")
	}
	if strings.Compare(nu.UserPassword, nu.UserPasswordConf) != 0 {

		return fmt.Errorf("passwords do not match")
	}
	if len(nu.Username) == 0 {

		return fmt.Errorf("username must be atleast 1 character long")
	}
	return nil
}

//ToUser converts the NewUser to a User, setting the
//PhotoURL and PassHash fields appropriately
func (nu *NewUser) ToUser() (*User, error) {
	gravPhotoURL := strings.ToLower(strings.Trim(nu.UserEmail, " "))

	hasher := md5.New()
	hasher.Write([]byte(gravPhotoURL))
	// photoURL := hex.EncodeToString(hasher.Sum(nil))

	user := &User{
		UserEmail: nu.UserEmail,
		Username:  nu.Username,
		UserFname: nu.UserFname,
		UserLname: nu.UserLname,
		PhotoUrl:  "https://ui-avatars.com/api/?+name=" + nu.UserFname + "+" + nu.UserLname,
		UserDOB:   nu.UserDOB,
	}

	err := user.SetPassword(nu.UserPassword)
	if err != nil {
		return nil, err
	}
	return user, nil
}

//FullName returns a string of the users full name with a space in between
func (u *User) FullName() string {
	if len(u.UserFname) == 0 || len(u.UserLname) == 0 {
		return u.UserFname + u.UserLname
	}
	return u.UserFname + " " + u.UserLname
}

//SetPassword hashes the password and stores it in the PassHash field
func (u *User) SetPassword(password string) error {
	hashPass, err := bcrypt.GenerateFromPassword([]byte(password), bcryptCost)
	if err != nil {
		return err
	}
	u.PasswordHash = hashPass
	return nil
}

//Authenticate compares the plaintext password against the stored hash
//and returns an error if they don't match, or nil if they do
func (u *User) Authenticate(password string) error {

	err := bcrypt.CompareHashAndPassword(u.PasswordHash, []byte(password))
	if err != nil {
		return err
	}
	return nil
}

//ApplyUpdates applies the updates to the user. An error
//is returned if the updates are invalid
func (u *User) ApplyUpdates(updates *Updates) error {
	if len(updates.UserFname) == 0 || len(updates.UserLname) == 0 {
		return fmt.Errorf("Name must be atleast 1 character long")
	}
	u.UserFname = updates.UserFname
	u.UserLname = updates.UserLname

	return nil
}

func (u *User) ApplyPasswordUpdate(update *PasswordUpdate) error {

	err := u.Authenticate(update.UserPassword)
	if err != nil {
		return fmt.Errorf("Error Wrong Password")
	}

	if len(update.UserNewPassword) < 6 {
		return fmt.Errorf("password must be atleast 6 characters")
	}
	if strings.Compare(update.UserNewPassword, update.UserNewPasswordConf) != 0 {
		return fmt.Errorf("passwords do not match")
	}

	hashPass, err := bcrypt.GenerateFromPassword([]byte(update.UserNewPassword), bcryptCost)
	if err != nil {
		fmt.Print("Error Crypt")
		return err
	}
	u.PasswordHash = hashPass
	return nil
}
func (u *User) ValidatePersonalUpdate(update *PersonalUpdate) error {
	_, err := mail.ParseAddress(update.UserEmail)
	if err != nil {
		return fmt.Errorf("invalid email: %s", err)
	}

	if len(update.Username) == 0 {

		return fmt.Errorf("username must be atleast 1 character long")
	}

	return nil
}
