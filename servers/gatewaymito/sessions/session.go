package sessions

import (
	"errors"
	"fmt"
	"net/http"
	"strings"
)

const headerAuthorization = "Authorization"
const paramAuthorization = "auth"
const schemeBearer = "Bearer "

//ErrNoSessionID is used when no session ID was found in the Authorization header
var ErrNoSessionID = errors.New("no session ID found in " + headerAuthorization + " header")

//ErrInvalidScheme is used when the authorization scheme is not supported
var ErrInvalidScheme = errors.New("authorization scheme not supported")

//BeginSession creates a new SessionID, saves the `sessionState` to the store, adds an
//Authorization header to the response with the SessionID, and returns the new SessionID
func BeginSession(signingKey string, store Store, sessionState interface{}, w http.ResponseWriter) (SessionID, error) {
	SeshID, err := NewSessionID(signingKey)
	if err != nil {
		return InvalidSessionID, fmt.Errorf("Error creating new session ID %s", err)
	}
	if err := store.Save(SeshID, sessionState); err != nil {
		return InvalidSessionID, err
	}
	bearerSid := schemeBearer + SeshID.String()
	w.Header().Add(headerAuthorization, bearerSid)
	return SeshID, nil
}

//GetSessionID extracts and validates the SessionID from the request headers
func GetSessionID(r *http.Request, signingKey string) (SessionID, error) {
	valAuth := r.Header.Get(headerAuthorization)
	if len(valAuth) == 0 {
		valAuth = r.URL.Query().Get(paramAuthorization)
		if len(valAuth) == 0 {
			return InvalidSessionID, ErrNoSessionID
		}

	}
	if !strings.HasPrefix(valAuth, schemeBearer) {
		return InvalidSessionID, ErrInvalidScheme
	}
	trimSeshID := strings.Trim(valAuth, schemeBearer)
	SeshID, err := ValidateID(trimSeshID, signingKey)
	if err != nil {
		return InvalidSessionID, fmt.Errorf("Error validating ID %s trimmed sesh id= %s , signing key = %s", err, trimSeshID, signingKey)
	}
	return SeshID, nil
}

//GetState extracts the SessionID from the request,
//gets the associated state from the provided store into
//the `sessionState` parameter, and returns the SessionID
func GetState(r *http.Request, signingKey string, store Store, sessionState interface{}) (SessionID, error) {
	SeshID, err := GetSessionID(r, signingKey)
	if err != nil {
		return InvalidSessionID, fmt.Errorf("Error getting session ID %s", err)
	}
	err = store.Get(SeshID, sessionState)
	if err != nil {
		return SeshID, fmt.Errorf("Error getting ID from redis store %s", err)
	}

	return SeshID, nil
}

//EndSession extracts the SessionID from the request,
//and deletes the associated data in the provided store, returning
//the extracted SessionID.
func EndSession(r *http.Request, signingKey string, store Store) (SessionID, error) {
	SeshID, err := GetSessionID(r, signingKey)
	if err != nil {
		return InvalidSessionID, fmt.Errorf("Error getting session ID %s", err)
	}
	err = store.Delete(SeshID)
	if err != nil {
		return InvalidSessionID, fmt.Errorf("Error deleting session ID from store %s", err)
	}
	return SeshID, nil
}