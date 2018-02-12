package sessions

import (
	"encoding/json"
	"fmt"
	"time"

	"github.com/go-redis/redis"
)

//RedisStore represents a session.Store backed by redis.
type RedisStore struct {
	//Redis client used to talk to redis server.
	Client *redis.Client
	//Used for key expiry time on redis.
	SessionDuration time.Duration
}

//NewRedisStore constructs a new RedisStore
func NewRedisStore(client *redis.Client, sessionDuration time.Duration) *RedisStore {
	//initialize and return a new RedisStore struct
	if client == nil {
		panic("nil pointer passed for client")
	}

	return &RedisStore{
		Client:          client,
		SessionDuration: sessionDuration,
	}
}

//Store implementation

//Save saves the provided `sessionState` and associated SessionID to the store.
//The `sessionState` parameter is typically a pointer to a struct containing
//all the data you want to associated with the given SessionID.
func (rs *RedisStore) Save(sid SessionID, sessionState interface{}) error {
	sessionStateJSON, err := json.Marshal(sessionState)
	if err != nil {
		return fmt.Errorf("error %s", err)
	}

	saveState := rs.Client.Set(sid.getRedisKey(), sessionStateJSON, rs.SessionDuration)

	return saveState.Err()
}

//Get populates `sessionState` with the data previously saved
//for the given SessionID
func (rs *RedisStore) Get(sid SessionID, sessionState interface{}) error {
	prevSessionState := rs.Client.Get(sid.getRedisKey())

	if prevSessionState.Err() != nil {
		if prevSessionState.Err() != redis.Nil {
			return ErrStateNotFound
		}
		return prevSessionState.Err()

	}

	realSessionState, err := prevSessionState.Bytes()
	if err != nil {
		return fmt.Errorf("error converting session state to bytes %s", err)
	}
	err = json.Unmarshal(realSessionState, sessionState)
	if err != nil {
		return fmt.Errorf("error unmarshaling json: %s", err)
	}
	getState := rs.Client.Expire(sid.getRedisKey(), rs.SessionDuration)

	return getState.Err()
}

//Delete deletes all state data associated with the SessionID from the store.
func (rs *RedisStore) Delete(sid SessionID) error {
	delState := rs.Client.Del(sid.getRedisKey())

	return delState.Err()
}

//getRedisKey() returns the redis key to use for the SessionID
func (sid SessionID) getRedisKey() string {
	return "sid:" + sid.String()
}