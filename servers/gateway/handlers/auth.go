package handlers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"sort"
	"time"

	"github.com/andrenguyener/mito/servers/gateway/models/users"
	"github.com/andrenguyener/mito/servers/gateway/sessions"
)

// UsersHandler allows new users to sign up (POST) or return all the users (GET)
func (ctx *Context) UsersHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "POST":
		if r.Body == nil {
			http.Error(w, "Response Body is empty", http.StatusBadRequest)
			return
		}

		// decode the request body into newUser struct
		decoder := json.NewDecoder(r.Body)
		newUser := &users.NewUser{}

		err := decoder.Decode(newUser)
		fmt.Println(newUser)
		if err != nil {
			http.Error(w, "Error decoding JSON: "+err.Error(), http.StatusBadRequest)
			return
		}

		// validate the new user
		err = newUser.Validate()
		if err != nil {
			http.Error(w, "Error validating new user: "+err.Error(), http.StatusBadRequest)
			return
		}

		// checks to see if there isn't already a user in the User Store with the same email
		user, err := ctx.UserStore.GetByEmail(newUser.UserEmail)
		if err != users.ErrUserNotFound && user != nil {
			http.Error(w, "Error email already exists: "+newUser.UserEmail, http.StatusBadRequest)
			return
		}

		// checks to see if there isn't already a user in the User Store with the same username
		user, err = ctx.UserStore.GetByUserName(newUser.Username)
		if err != users.ErrUserNotFound && user != nil {
			http.Error(w, "Error username already exists: "+newUser.Username, http.StatusBadRequest)
			return
		}

		// _, err = ctx.UserStore.GetByID(109)
		// if err != nil {
		// 	http.Error(w, "fail error "+err.Error(), http.StatusBadRequest)
		// }

		// inserts the new user into User Store
		user, err = ctx.UserStore.Insert(newUser)
		if err != nil {
			http.Error(w, "Error inserting user: "+err.Error(), http.StatusBadRequest)
			return
		}

		// begins a new session with the context session signing key and a new session state
		sessionState := &SessionState{
			Time: time.Now(),
			User: user,
		}
		_, err = sessions.BeginSession(ctx.SessionKey, ctx.SessionStore, sessionState, w)
		if err != nil {
			http.Error(w, "Error beginning session: "+err.Error(), http.StatusInternalServerError)
			return
		}

		// ctx.TrieStore.Insert(user.Email, user.ID)
		// ctx.TrieStore.Insert(user.UserName, user.ID)
		// ctx.TrieStore.Insert(user.FirstName, user.ID)
		// ctx.TrieStore.Insert(user.LastName, user.ID)
		w.WriteHeader(http.StatusCreated)
		respond(w, user)

	case "GET":
		if len(r.Header.Get("Authorization")) == 0 {
			http.Error(w, "Error user is not authorized", http.StatusUnauthorized)
		} else {
			searchPrefix := r.URL.Query().Get("q")
			blank := []string{}
			if len(searchPrefix) == 0 {
				json.NewEncoder(w).Encode(blank)
			} else {
				searchResults := ctx.TrieStore.Search(20, searchPrefix)
				users, err := ctx.UserStore.ConvertToUsers(searchResults)
				if err != nil {
					http.Error(w, fmt.Sprintf("error converting to users: %v", err), http.StatusInternalServerError)
					return
				}
				sort.Slice(users, func(i, j int) bool {
					return users[i].UserId < users[j].UserId
				})
				w.Header().Add(headerContentType, contentTypeJSON)
				json.NewEncoder(w).Encode(users)
			}

		}
	default:
		http.Error(w, "invalid status method", http.StatusMethodNotAllowed)
		return
	}
}

// UsersMeHandler allows users to get their current session state
func (ctx *Context) UsersMeHandler(w http.ResponseWriter, r *http.Request) {

	// get the session state
	sessionState := &SessionState{}

	// get the state of the browser that is accessing their page
	sessionID, err := sessions.GetState(r, ctx.SessionKey, ctx.SessionStore, sessionState)
	if err != nil {
		http.Error(w, "Error cannot get session state: "+err.Error(), http.StatusUnauthorized)
		return
	}
	sessionUser := sessionState.User
	switch r.Method {
	case "GET":
		// respond to the client with the session state's User field
		respond(w, sessionUser)
	case "PATCH":

		// decode the request body into users userupdate struct
		userUpdates := &users.Updates{}
		err = json.NewDecoder(r.Body).Decode(userUpdates)
		if err != nil {
			http.Error(w, "Error cannot decode JSON updates: "+err.Error(), http.StatusBadRequest)
		}

		// updates the user in mongo stroe
		err = ctx.UserStore.Update(sessionUser.UserId, userUpdates)

		if err != nil {
			http.Error(w, "Error cannot update user: "+err.Error(), http.StatusBadRequest)
		}

		// deletes previous name fields from trie store
		ctx.TrieStore.Remove(sessionState.User.UserFname, sessionState.User.UserId)
		ctx.TrieStore.Remove(sessionState.User.UserLname, sessionState.User.UserId)

		// update the session state with the user
		sessionState.User.UserFname = userUpdates.UserFname
		sessionState.User.UserLname = userUpdates.UserLname

		err = ctx.SessionStore.Save(sessionID, sessionState)
		if err != nil {
			http.Error(w, "Error cannot save session: "+err.Error(), http.StatusBadRequest)
		}

		// Insert the updated user fields into the trie.
		ctx.TrieStore.Insert(sessionState.User.UserFname, sessionState.User.UserId)
		ctx.TrieStore.Insert(sessionState.User.UserLname, sessionState.User.UserId)

		respond(w, sessionUser)

	default:
		http.Error(w, "method must be GET or PATCH", http.StatusMethodNotAllowed)
		return
	}
}

// SessionsHandler allows existing users to sign in
func (ctx *Context) SessionsHandler(w http.ResponseWriter, r *http.Request) {
	// The request must be POST
	if r.Method == "POST" {

		if r.Body == nil {
			http.Error(w, "Response Body is empty", http.StatusBadRequest)
			return
		}

		decoder := json.NewDecoder(r.Body)
		newSession := &users.Credentials2{}

		// Decodes the request body in user credentials struct
		if err := decoder.Decode(newSession); err != nil {
			http.Error(w, "invalid JSON", http.StatusBadRequest)
			return
		}

		// Gets the user with the email from User Store.
		user, err := ctx.UserStore.GetByEmail(newSession.Email)
		if err != nil {
			http.Error(w, "invalid credentials", http.StatusUnauthorized)
			return
		}

		// Authenticates the user with the provided password
		err = user.Authenticate(newSession.Password)
		if err != nil {
			http.Error(w, "invalid credentials", http.StatusUnauthorized)
			return
		}

		// Begin new session by getting the session state
		sessionState := &SessionState{
			Time: time.Now(),
			User: user,
		}

		// Begins a new session with the context session signing key and the state
		_, err = sessions.BeginSession(ctx.SessionKey, ctx.SessionStore, sessionState, w)
		if err != nil {
			http.Error(w, "Error beginning session: "+err.Error(), http.StatusInternalServerError)
			return
		}

		respond(w, user)

	} else {
		http.Error(w, "request method must be POST", http.StatusMethodNotAllowed)
		return
	}
}

// SessionsMineHandler allows authenticated users to sign out
func (ctx *Context) SessionsMineHandler(w http.ResponseWriter, r *http.Request) {
	// The request must be DELETE
	if r.Method == "DELETE" {

		// Gets the current session and ends it, deleting from redis
		_, err := sessions.EndSession(r, ctx.SessionKey, ctx.SessionStore)
		if err != nil {
			http.Error(w, "Error deleting session: "+err.Error(), http.StatusUnauthorized)
			return
		}

		w.Write([]byte("signed out"))
	} else {
		http.Error(w, "invalid status method", http.StatusMethodNotAllowed)
		return
	}
}

func respond(w http.ResponseWriter, value interface{}) {
	w.Header().Add(headerContentType, contentTypeJSON)
	if err := json.NewEncoder(w).Encode(value); err != nil {
		http.Error(w, fmt.Sprintf("error encoding response value to JSON: %v", err), http.StatusInternalServerError)
	}
}
