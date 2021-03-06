package users

import (
	"database/sql"
	"encoding/base64"
	"encoding/hex"
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

//GetByID returns the User with the given ID
func (ss *SqlStore) GetByID(id int) (*User, error) {
	user := &User{}
	// var userString string
	tsql := fmt.Sprintf("EXEC uspcGetUserById @UserId;")

	rows, err := ss.database.Query(
		tsql,
		sql.Named("UserId", id))
	if err != nil {
		return nil, fmt.Errorf("Error retrieving ID %s", err)
	}

	defer rows.Close()
	for rows.Next() {
		if err := rows.Scan(&user.UserId, &user.UserFname, &user.UserLname, &user.UserEmail, &user.PhotoUrl, &user.UserDOB, &user.Username, &user.NumFriends, &user.ProfileImage); err != nil {
			log.Fatal(err)
		}
		// if err := json.Unmarshal([]byte(userString), user); err != nil {
		// 	log.Fatal(err)
		// }

	}
	if err := rows.Err(); err != nil {
		log.Fatal(err)
	}
	user.ProfileImageString = hex.EncodeToString(user.ProfileImage)
	return user, nil
}

//GetByEmail returns the User with the given email
func (ss *SqlStore) GetByEmail(email string) (*User, error) {
	// user := &User{}
	// var userString string
	// tsql := fmt.Sprintf("EXEC uspGetUserByUserEmail @Useremail;")

	// rows, err := ss.database.Query(
	// 	tsql,
	// 	sql.Named("Useremail", email))
	// if err != nil {
	// 	return nil, ErrUserNotFound
	// }
	// defer rows.Close()
	// for rows.Next() {
	// 	if err := rows.Scan(&userString); err != nil {
	// 		log.Fatal(err)
	// 	}
	// 	fmt.Printf("something something")
	// 	if err := json.Unmarshal([]byte(userString), user); err != nil {
	// 		log.Fatal(err)
	// 	}
	// 	fmt.Println(user)
	// 	// fmt.Println(user.PasswordHash)
	// }
	// if err := rows.Err(); err != nil {
	// 	log.Fatal(err)
	// }

	// return user, nil
	user := &User{}
	tsql := fmt.Sprintf("EXEC uspcGetUserByUserEmail @Useremail;")

	rows, err := ss.database.Query(
		tsql,
		sql.Named("Useremail", email))
	if err != nil {
		return nil, ErrUserNotFound
	}

	defer rows.Close()
	for rows.Next() {
		if err := rows.Scan(&user.UserId, &user.UserFname, &user.UserLname, &user.UserEmail, &user.PasswordHash, &user.PhotoUrl, &user.UserDOB, &user.Username, &user.NumFriends, &user.IsDelete, &user.ProfileImageId, &user.ProfileImage, &user.EbayToken); err != nil {
			log.Fatalf("Error scanning row %v", err)
		}

	}
	if err := rows.Err(); err != nil {
		log.Fatalf("Error in row %v", err)
	}
	// user.ProfileImageString = hex.EncodeToString(user.ProfileImage)
	user.ProfileImageString = base64.StdEncoding.EncodeToString(user.ProfileImage)
	return user, nil
}

//GetByUserName returns the User with the given Username
func (ss *SqlStore) GetByUserName(username string) (*User, error) {
	user := &User{}
	// var userString string
	tsql := fmt.Sprintf("EXEC uspcGetUserByUsername @Username;")

	rows, err := ss.database.Query(
		tsql,
		sql.Named("Username", username))
	if err != nil {
		return nil, ErrUserNotFound
	}

	defer rows.Close()
	for rows.Next() {
		if err := rows.Scan(&user.UserId, &user.UserFname, &user.UserLname, &user.UserEmail, &user.PasswordHash, &user.PhotoUrl, &user.UserDOB, &user.Username, &user.NumFriends, &user.IsDelete, &user.ProfileImageId, &user.ProfileImage, &user.EbayToken); err != nil {
			log.Fatalf("Error scanning row %v", err)
		}
		// if err := json.Unmarshal([]byte(userString), user); err != nil {
		// 	log.Fatal(err)
		// }

	}
	if err := rows.Err(); err != nil {
		log.Fatalf("Error in row %v", err)
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
	// var newUserId int64
	_, err = ss.database.Exec("uspcInsertUser",
		sql.Named("UserFname", user.UserFname),
		sql.Named("UserLname", user.UserLname),
		sql.Named("UserEmail", user.UserEmail),
		sql.Named("PasswordHash", user.PasswordHash),
		sql.Named("PhotoUrl", user.PhotoUrl),
		sql.Named("UserDOB", user.UserDOB),
		sql.Named("Username", user.Username))
	if err != nil {
		return nil, fmt.Errorf("Error inserting user %s", err)
	}

	returnUser := &User{}
	tsql := fmt.Sprintf("EXEC uspcGetUserByUserEmail @Useremail;")

	rows, err := ss.database.Query(
		tsql,
		sql.Named("Useremail", user.UserEmail))
	if err != nil {
		return nil, ErrUserNotFound
	}

	defer rows.Close()
	for rows.Next() {
		if err := rows.Scan(&returnUser.UserId,
			&returnUser.UserFname,
			&returnUser.UserLname,
			&returnUser.UserEmail,
			&returnUser.PasswordHash,
			&returnUser.PhotoUrl,
			&returnUser.UserDOB,
			&returnUser.Username,
			&returnUser.NumFriends,
			&returnUser.IsDelete,
			&returnUser.ProfileImageId,
			&returnUser.ProfileImage,
			&returnUser.EbayToken); err != nil {
			log.Fatalf("Error scanning row %v", err)
		}

	}
	if err := rows.Err(); err != nil {
		log.Fatalf("Error in row %v", err)
	}
	// user.ProfileImageString = hex.EncodeToString(user.ProfileImage)
	returnUser.ProfileImageString = base64.StdEncoding.EncodeToString(returnUser.ProfileImage)
	return returnUser, nil

	// user := &User{}
	// userToInsert, err := newUser.ToUser()

	// tsql := fmt.Sprintf("EXEC uspcInsertUser @UserFname, @UserLname, @UserEmail, @PasswordHash, @PhotoUrl, @UserDOB, @Username;")

	// rows, err := ss.database.Query(
	// 	tsql,
	// 	sql.Named("UserFname", "new"),
	// 	sql.Named("UserLname", "user"),
	// 	sql.Named("UserEmail", "newuser3@gmail.com"),
	// 	sql.Named("PasswordHash", []byte("hello world")),
	// 	sql.Named("PhotoUrl", "gravatar.com"),
	// 	sql.Named("UserDOB", "01/01/2000"),
	// 	sql.Named("Username", "newuser3"))
	// if err != nil {
	// 	fmt.Println(err)
	// 	return nil, ErrUserNotFound
	// }

	// defer rows.Close()
	// for rows.Next() {
	// 	if err := rows.Scan(&user.UserId, &user.UserFname, &user.UserLname, &user.UserEmail, &user.PasswordHash, &user.PhotoUrl, &user.UserDOB, &user.Username, &user.NumFriends, &user.IsDelete, &user.ProfileImageId, &user.ProfileImage, &user.EbayToken); err != nil {
	// 		log.Fatalf("Error scanning row %v", err)
	// 	}

	// }
	// if err := rows.Err(); err != nil {
	// 	log.Fatalf("Error in row %v", err)
	// }

	// user.ProfileImageString = base64.StdEncoding.EncodeToString(user.ProfileImage)
	// return user, nil
}

//Update applies passwordUpdates to the given user ID
func (ss *SqlStore) Update(userID int, updates *PasswordUpdate) error {

	// col := ms.collection
	// userupdates := bson.M{"$set": updates}
	// err := col.UpdateId(userID, userupdates)
	// return err
	return nil
}

//UpdatePassword applies updated password to a given user
func (ss *SqlStore) UpdatePassword(user *User) error {
	_, err := ss.database.Exec("uspcUpdatePassword",
		sql.Named("UserId", user.UserId),
		sql.Named("NewPass", user.PasswordHash))
	if err != nil {
		return fmt.Errorf("Error updating user password %s", err)
	}

	return nil
}

func (ss *SqlStore) UpdatePersonal(user *PersonalUpdate, userId int) error {
	_, err := ss.database.Exec("uspcUpdatePassword",
		sql.Named("UserId", userId),
		sql.Named("NewPass", user.UserDOB))
	if err != nil {
		return fmt.Errorf("Error updating user password %s", err)
	}
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

	tsql := fmt.Sprintf("EXEC uspcGetAllUsers")

	rows, err := ss.database.Query(
		tsql)
	if err != nil {
		return nil, ErrUserNotFound
	}

	defer rows.Close()
	for rows.Next() {
		user := &User{}
		if err := rows.Scan(&user.UserId, &user.UserFname, &user.UserLname, &user.UserEmail, &user.PhotoUrl, &user.UserDOB, &user.Username, &user.NumFriends); err != nil {
			log.Fatal(err)
		}
		users = append(users, user)

	}
	if err := rows.Err(); err != nil {
		log.Fatal(err)
	}

	return users, nil
}
