package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"net/http/httputil"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/mito/servers/gatewaymito/models/users"
	"github.com/mito/servers/gatewaymito/sessions"
	"github.com/streadway/amqp"

	"database/sql"

	_ "github.com/denisenkom/go-mssqldb"
	"github.com/go-redis/redis"
	"github.com/mito/servers/gatewaymito/handlers"
)

// Gets the current user of the session
func GetCurrentUser(r *http.Request, ctx *handlers.Context) *users.User {
	sessionState := &handlers.SessionState{}
	_, err := sessions.GetState(r, ctx.SessionKey, ctx.SessionStore, sessionState)
	if err != nil {
		fmt.Printf("Error cannot get session state: "+err.Error(), http.StatusUnauthorized)
	}
	sessionUser := sessionState.User
	return sessionUser
}

// Directs the request to the correct microservice, attaches the user as a Header
func NewServiceProxy(addrs []string, ctx *handlers.Context) *httputil.ReverseProxy {
	nextIndex := 0
	mx := sync.Mutex{}
	return &httputil.ReverseProxy{
		Director: func(r *http.Request) {
			user := GetCurrentUser(r, ctx)
			userJSON, err := json.Marshal(user)
			if err != nil {
				log.Printf("error marshaling user: %v", err)
			}
			r.Header.Set("X-User", string(userJSON))

			r.Header.Set("Content-Type", "application/json")
			mx.Lock()
			r.URL.Host = addrs[nextIndex%len(addrs)]
			nextIndex++
			mx.Unlock()
			r.URL.Scheme = "http"
		},
	}
}

const summaryPath = "/v1/summary"

// Replace with your own connection parameters
var server = "projectmito.database.windows.net"
var user = "mitoteam"
var password = "JABS2018!"
var db *sql.DB

//main is the main entry point for the server
func main() {
	addr := os.Getenv("ADDR")
	sessionKey := os.Getenv("SESSIONKEY")
	redisAddr := os.Getenv("REDISADDR")

	mitoNodeaddr := os.Getenv("MITONODEADDR")
	if len(mitoNodeaddr) == 0 {
		mitoNodeaddr = "localhost:4004"
	}

	if len(sessionKey) == 0 {
		sessionKey = "password"
	}

	if len(addr) == 0 {
		addr = "localhost:4000"
	}

	// Connection to Redis client
	if len(redisAddr) == 0 {
		redisAddr = "localhost:6379"
	}

	redisClient := redis.NewClient(&redis.Options{
		Addr: redisAddr,
	})
	redisStore := sessions.NewRedisStore(redisClient, time.Hour*24*365)

	// Connection to SQL
	// Create connection string
	connString := fmt.Sprintf("server=%s;user id=%s;password=%s;database=projectmito",
		server, user, password)

	// Create connection pool
	db, err := sql.Open("sqlserver", connString)
	if err != nil {
		log.Fatal("Error creating connection pool: " + err.Error())
	}
	sqlStore := users.NewSqlStore(db, "projectmito", "USERS")
	log.Printf("Connected!\n")

	// Close the database connection pool after program executes
	defer db.Close()

	// Adds the Trie Store
	// trieStore := mongoStore.Index()
	trieStore := sqlStore.Index()

	// Connection to RabbitMQ
	mqAddr := os.Getenv("MQADDR")
	if len(mqAddr) == 0 {
		mqAddr = "localhost:5672"
	}
	mqURL := fmt.Sprintf("amqp://%s", mqAddr)
	conn, err := amqp.Dial(mqURL)
	if err != nil {
		log.Fatalf("error connecting to RabbitMQ: %v", err)
	}
	channel, err := conn.Channel()
	if err != nil {
		log.Fatalf("error creating channel: %v", err)
	}

	q, err := channel.QueueDeclare("testQ", false, false, false, false, nil)

	msgs, err := channel.Consume(q.Name, "", true, false, false, false, nil)

	notifier := handlers.NewNotifier(msgs)

	ctx := &handlers.Context{
		SessionKey:   sessionKey,
		SessionStore: redisStore,
		UserStore:    sqlStore,
		TrieStore:    trieStore,
		Notifier:     notifier,
	}

	tlskey := os.Getenv("TLSKEY")
	if len(tlskey) == 0 {
		tlskey = "./../tls/privkey.pem"
	}

	tlscert := os.Getenv("TLSCERT")
	if len(tlscert) == 0 {
		tlscert = "./../tls/fullchain.pem"
	}

	if len(tlskey) == 0 || len(tlscert) == 0 {
		log.Fatal("please set TLSKEY and TLSCERT")
	}

	splitMitoNodeAddrs := strings.Split(mitoNodeaddr, ",")
	// splitSummaryAddrs := strings.Split(summaryaddr, ",")

	mux := http.NewServeMux()
	mux.HandleFunc("/v1/users", ctx.UsersHandler)
	mux.HandleFunc("/v1/users/me", ctx.UsersMeHandler)
	mux.HandleFunc("/v1/users/all", ctx.UsersAllHandler)
	mux.HandleFunc("/v1/users/validate", ctx.UsersValidateHandler)
	mux.HandleFunc("/v1/users/password", ctx.UsersPasswordHandler)
	mux.HandleFunc("/v1/users/personal", ctx.UsersPersonalHandler)
	mux.HandleFunc("/v1/users/id", ctx.UsersIDHandler)
	mux.HandleFunc("/v1/sessions", ctx.SessionsHandler)
	mux.HandleFunc("/v1/sessions/mine", ctx.SessionsMineHandler)

	corsHandler := handlers.NewCORSHandler(mux)
	mux.Handle("/v1/ws", ctx.NewWebSocketsHandler(notifier))
	fmt.Printf("server is listening at https://%s\n", addr)

	mux.Handle("/v1/address", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/address/", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/friend", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/friend/", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/amazonhash", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/amazonhash/", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/amazonhashtest", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/amazonhashtest/", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/amazonsearch", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/amazonsearch/", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/cart", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/cart/", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/order", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/order/", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/package", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/package/", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/payment", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/payment/", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/feed", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/feed/", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/notification", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/notification/", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/image", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/image/", NewServiceProxy(splitMitoNodeAddrs, ctx))
	log.Fatal(http.ListenAndServeTLS(addr, tlscert, tlskey, corsHandler))
}
