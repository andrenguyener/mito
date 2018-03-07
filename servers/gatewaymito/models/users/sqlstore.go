package users

import (
	"database/sql"
	"fmt"
	"log"

	"github.com/mito/servers/gatewaymito/indexes"
)

//SqlStore implements Store for SqlStore
type SqlStore struct {
	database *sql.DB
	table    string
}

//NewSql constructs a new SqlStore, given a live database session, a database name, and a table name
func NewSqlStore(database *sql.DB, dbname string, tablename string) *SqlStore {
	if database == nil {
		panic("nil pointer passed for database")
	}
	return &SqlStore{
		database: database,
		table:    fmt.Sprintf("[%s].[dbo].[%s]", dbname, tablename),
	}
}

type UpdateUser struct {
	UserFname string `json:"userFname"`
	UserLname string `json:"userLname"`
	UserEmail string `json:"userEmail"`
	Username  string `json:"username"`
	UserDOB   string `json:"userDOB"`
	PhotoURL  string `json:"photoURL"`
}

type UpdateUserPassword struct {
	UserPassword     string `json:"password"`
	UserPasswordConf string `json:"passwordConf"`
}

//GetByID returns the User with the given ID
func (ss *SqlStore) GetByID(id int) (*User, error) {
	user := &User{}
	tsql := fmt.Sprintf("EXEC GetUserByID @UserId;")

	rows, err := ss.database.Query(
		tsql,
		sql.Named("UserId", id))
	if err != nil {
		return nil, fmt.Errorf("Error retrieving ID %s", err)
	}

	defer rows.Close()
	for rows.Next() {
		if err := rows.Scan(&user.UserId, &user.UserFname, &user.UserLname, &user.UserEmail, &user.PhotoUrl, &user.UserDOB, &user.Username); err != nil {
			log.Fatal(err)
		}
		fmt.Println(user)
	}
	if err := rows.Err(); err != nil {
		log.Fatal(err)
	}
	return user, nil
}

//GetByEmail returns the User with the given email
func (ss *SqlStore) GetByEmail(email string) (*User, error) {
	user := &User{}
	tsql := fmt.Sprintf("EXEC GetUserByUserEmail @Useremail;")

	rows, err := ss.database.Query(
		tsql,
		sql.Named("Useremail", email))
	if err != nil {
		return nil, ErrUserNotFound
	}

	defer rows.Close()
	for rows.Next() {
		if err := rows.Scan(&user.UserId, &user.UserFname, &user.UserLname, &user.UserEmail, &user.PasswordHash, &user.PhotoUrl, &user.UserDOB, &user.Username); err != nil {
			log.Fatal(err)
		}
		fmt.Println(user)
	}
	if err := rows.Err(); err != nil {
		log.Fatal(err)
	}

	return user, nil
}

//GetByUserName returns the User with the given Username
func (ss *SqlStore) GetByUserName(username string) (*User, error) {
	user := &User{}
	tsql := fmt.Sprintf("EXEC GetUserByUsername @Username;")

	rows, err := ss.database.Query(
		tsql,
		sql.Named("Username", username))
	if err != nil {
		return nil, ErrUserNotFound
	}

	defer rows.Close()
	for rows.Next() {
		if err := rows.Scan(&user.UserId, &user.UserFname, &user.UserLname, &user.UserEmail, &user.PhotoUrl, &user.UserDOB, &user.Username); err != nil {
			log.Fatal(err)
		}
		fmt.Println(user)
	}
	if err := rows.Err(); err != nil {
		log.Fatal(err)
	}

	return user, nil
}

//Insert converts the NewUser to a User, inserts
//it into the database, and returns it
func (ss *SqlStore) Insert(newUser *NewUser) (*User, error) {
	user, err := newUser.ToUser()
	if err != nil {
		return nil, fmt.Errorf("Error converting new user to user %s", err)
	}
	var newUserId int64
	_, err = ss.database.Exec("insertUser",
		sql.Named("UserFname", user.UserFname),
		sql.Named("UserLname", user.UserLname),
		sql.Named("UserEmail", user.UserEmail),
		sql.Named("PasswordHash", user.PasswordHash),
		sql.Named("PhotoUrl", user.PhotoUrl),
		sql.Named("UserDOB", user.UserDOB),
		sql.Named("Username", user.Username),
		sql.Named("RetNewUserId", sql.Out{Dest: &newUserId}))
	if err != nil {
		return nil, fmt.Errorf("Error inserting user %s", err)
	}
	user.UserId = int(newUserId)
	fmt.Println(user)

	return user, err
}

//Update applies UserUpdates to the given user ID
func (ss *SqlStore) Update(userID int, updates *Updates) error {

	// col := ms.collection
	// userupdates := bson.M{"$set": updates}
	// err := col.UpdateId(userID, userupdates)
	// return err
	return nil
}

//Delete deletes the user with the given ID
func (ss *SqlStore) Delete(userID int) error {
	// if err := ms.collection.RemoveId(userID); err != nil {
	// 	return fmt.Errorf("Error deleting user ID %s", err)
	// }
	return nil
}

// Index stores all users email, username, lastname, and firstname into a trie.
func (ss *SqlStore) Index() *indexes.Trie {
	// user := &User{}
	trie := indexes.NewTrie()

	// Iterate all users from database one at a time.
	// iter := ms.collection.Find(nil).Iter()

	// for iter.Next(user) {
	// 	trie.Insert(user.Email, user.ID)
	// 	trie.Insert(user.UserName, user.ID)
	// 	trie.Insert(user.LastName, user.ID)
	// 	trie.Insert(user.FirstName, user.ID)
	// }

	// Report any errors that occurred.
	// if err := iter.Err(); err != nil {
	// 	fmt.Printf("error iterating stored documents: %v", err)
	// }

	return trie
}

// ConvertToUsers converts all keys(User IDs) in a given map to a slice of User.
func (ss *SqlStore) ConvertToUsers(userIDs map[int]bool) ([]*User, error) {
	users := []*User{}
	// for userID := range userIDs {
	// 	user, err := store.GetByID(userID)
	// 	if err != nil {
	// 		return nil, fmt.Errorf("error getting user: %v", err)
	// 	}
	// 	users = append(users, user)
	// }

	return users, nil
}

//GetAll returns all users
func (ss *SqlStore) GetAll() ([]*User, error) {
	users := []*User{}
	// err := ms.collection.Find(nil).All(&users)
	// if err != nil {
	// 	return nil, err
	// }
	return users, nil
}
