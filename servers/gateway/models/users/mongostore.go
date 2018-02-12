package users

import (
	"fmt"

	"github.com/andrenguyener/mito/servers/gateway/indexes"
	"gopkg.in/mgo.v2"
	"gopkg.in/mgo.v2/bson"
)

type updateDoc struct {
	FirstName string
	LastName  string
}

//MongoStore implements Store for MongoDB
type MongoStore struct {
	session    *mgo.Session
	collection *mgo.Collection
}

//NewMongoStore constructs a new MongoStore, given a live mgo.Session, a database name, and a collection name
func NewMongoStore(sess *mgo.Session, dbname string, collname string) *MongoStore {
	if sess == nil {
		panic("nil pointer passed for session")
	}
	return &MongoStore{
		session:    sess,
		collection: sess.DB(dbname).C(collname),
	}
}

//GetByID returns the User with the given ID
func (ms *MongoStore) GetByID(id bson.ObjectId) (*User, error) {
	user := &User{}
	err := ms.collection.FindId(id).One(user)
	if err != nil {
		return nil, fmt.Errorf("Error could not find user by ID %s", err)
	}
	return user, nil
}

//GetByEmail returns the User with the given email
func (ms *MongoStore) GetByEmail(email string) (*User, error) {
	user := &User{}
	err := ms.collection.Find(bson.M{"email": email}).One(user)
	if err == mgo.ErrNotFound {
		return nil, ErrUserNotFound
	}
	return user, nil
}

//GetByUserName returns the User with the given Username
func (ms *MongoStore) GetByUserName(username string) (*User, error) {
	user := &User{}
	err := ms.collection.Find(bson.M{"username": username}).One(user)
	if err == mgo.ErrNotFound {
		return nil, ErrUserNotFound
	}
	return user, nil
}

//Insert converts the NewUser to a User, inserts
//it into the database, and returns it
func (ms *MongoStore) Insert(newUser *NewUser) (*User, error) {

	user, err := newUser.ToUser()
	if err != nil {
		return nil, fmt.Errorf("Error converting new user to user %s", err)
	}
	if err := ms.collection.Insert(user); err != nil {
		return nil, fmt.Errorf("Error inserting user %s", err)
	}
	return user, nil
}

//Update applies UserUpdates to the given user ID
func (ms *MongoStore) Update(userID bson.ObjectId, updates *Updates) error {

	col := ms.collection
	userupdates := bson.M{"$set": updates}
	err := col.UpdateId(userID, userupdates)
	return err

}

//Delete deletes the user with the given ID
func (ms *MongoStore) Delete(userID bson.ObjectId) error {
	if err := ms.collection.RemoveId(userID); err != nil {
		return fmt.Errorf("Error deleting user ID %s", err)
	}
	return nil
}

// Index stores all users email, username, lastname, and firstname into a trie.
func (ms *MongoStore) Index() *indexes.Trie {
	user := &User{}
	trie := indexes.NewTrie()

	// Iterate all users from database one at a time.
	iter := ms.collection.Find(nil).Iter()

	for iter.Next(user) {
		trie.Insert(user.Email, user.ID)
		trie.Insert(user.UserName, user.ID)
		trie.Insert(user.LastName, user.ID)
		trie.Insert(user.FirstName, user.ID)
	}

	// Report any errors that occurred.
	if err := iter.Err(); err != nil {
		fmt.Printf("error iterating stored documents: %v", err)
	}

	return trie
}


// ConvertToUsers converts all keys(User IDs) in a given map to a slice of User.
func (store *MongoStore) ConvertToUsers(userIDs map[bson.ObjectId]bool) ([]*User, error) {
	users := []*User{}
	for userID := range userIDs {
		user, err := store.GetByID(userID)
		if err != nil {
			return nil, fmt.Errorf("error getting user: %v", err)
		}
		users = append(users, user)
	}

	return users, nil
}

//GetAll returns all users
func (ms *MongoStore) GetAll() ([]*User, error) {
	users := []*User{}
	err := ms.collection.Find(nil).All(&users)
	if err != nil {
		return nil, err
	}
	return users, nil
}
