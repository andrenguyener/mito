package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"net/http/httputil"
	"os"
	"sync"
	"time"

	"github.com/andrenguyener/mito/servers/gateway/models/users"
	"github.com/andrenguyener/mito/servers/gateway/sessions"
	"github.com/streadway/amqp"
	mgo "gopkg.in/mgo.v2"

	"github.com/go-redis/redis"
	"github.com/andrenguyener/mito/servers/gateway/handlers"
	_ "github.com/denisenkom/go-mssqldb"
	"database/sql"
	"context"
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
	dbAddr := os.Getenv("DBADDR")

	// messagesaddr := os.Getenv("MESSAGESSVCADDR")
	// if len(messagesaddr) == 0 {
	// 	messagesaddr := "localhost:4004"
	// }
	// summaryaddr := os.Getenv("SUMMARYSVCADDR")
	// if len(summaryaddr) == 0 {
	// 	summaryaddr := "localhost:80"
	// }

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
	redisStore := sessions.NewRedisStore(redisClient, time.Hour)

	// Connection to Mongo
	if len(dbAddr) == 0 {
		dbAddr = "localhost:27017"
	}
	sess, err := mgo.Dial(dbAddr)
	if err != nil {
		log.Fatalf("error dialing mongosss: %v\n", err)
	}
	mongoStore := users.NewMongoStore(sess, "mongo", "users")

	// Adds the Trie Store
	trieStore := mongoStore.Index()

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
		UserStore:    mongoStore,
		TrieStore:    trieStore,
		Notifier:     notifier,
	}

	// tlskey := os.Getenv("TLSKEY")
	tlskey := "./../tls/privkey.pem"
	// tlscert := os.Getenv("TLSCERT")
	tlscert := "./../tls/fullchain.pem"
	if len(tlskey) == 0 || len(tlscert) == 0 {
		log.Fatal("please set TLSKEY and TLSCERT")
	}

	// splitMessagesAddrs := strings.Split(messagesaddr, ",")
	// splitSummaryAddrs := strings.Split(summaryaddr, ",")



    // Create connection string
	connString := fmt.Sprintf("server=%s;user id=%s;password=%s;database=projectmito",
		server, user, password)

    // Create connection pool
	db, err = sql.Open("sqlserver", connString)
	if err != nil {
		log.Fatal("Error creating connection pool: " + err.Error())
	}
    log.Printf("Connected!\n")

    // Close the database connection pool after program executes
    defer db.Close()

    SelectVersion()

	mux := http.NewServeMux()
	mux.HandleFunc("/v1/users", ctx.UsersHandler)
	mux.HandleFunc("/v1/users/me", ctx.UsersMeHandler)

	mux.HandleFunc("/v1/sessions", ctx.SessionsHandler)
	mux.HandleFunc("/v1/sessions/mine", ctx.SessionsMineHandler)

	corsHandler := handlers.NewCORSHandler(mux)
	mux.Handle("/v1/ws", ctx.NewWebSocketsHandler(notifier))
	fmt.Printf("server is listening at https://%s\n", addr)
	
	// mux.Handle("/v1/channels", NewServiceProxy(splitMessagesAddrs, ctx))
	// mux.Handle("/v1/channels/", NewServiceProxy(splitMessagesAddrs, ctx))
	// mux.Handle("/v1/messages/", NewServiceProxy(splitMessagesAddrs, ctx))
	// mux.Handle("/v1/summary", NewServiceProxy(splitSummaryAddrs, ctx))
	// mux.Handle("/v1/payments", NewServiceProxy(splitMessagesAddrs, ctx))
	// mux.Handle("/v1/payments/", NewServiceProxy(splitMessagesAddrs, ctx))
	// mux.Handle("/v1/email", NewServiceProxy(splitMessagesAddrs, ctx))
	log.Fatal(http.ListenAndServeTLS(addr, tlscert, tlskey, corsHandler))
}

// Gets and prints SQL Server version
func SelectVersion(){
    // Use background context
    ctx := context.Background()

    // Ping database to see if it's still alive.
    // Important for handling network issues and long queries.
    err := db.PingContext(ctx)
	if err != nil {
		log.Fatal("Error pinging database: " + err.Error())
	}

	var result string

    // Run query and scan for result
	err = db.QueryRowContext(ctx, "SELECT * FROM [projectmito].[dbo].[USER]").Scan(&result)
	if err != nil {
        log.Fatal("Scan failed:", err.Error())
    }
	fmt.Printf("%s\n", result)
	
	// tsql := fmt.Sprintf("SELECT * FROM [USER]")

	// var result3 string

    // // Execute non-query with named parameters
    // result3, err = db.ExecContext(ctx, tsql)

	// fmt.Printf(result3)


	// tsql := fmt.Sprintf("SELECT * FROM [projectmito].[dbo].[USER]")

    // // Execute query
    // rows, err := db.QueryContext(ctx, tsql)
    // if err != nil {
    //     log.Fatal("Error reading rows: " + err.Error())
    // }

    // defer rows.Close()

    // var count int = 0

    // // Iterate through the result set.
    // for rows.Next() {
    //     var name, location string
    //     var id int

    //     // Get values from row.
    //     err := rows.Scan(&id, &name, &location)
    //     if err != nil {
    //         log.Fatal("Error reading rows: " + err.Error())
    //     }

    //     fmt.Printf("ID: %d, Name: %s, Location: %s\n", id, name, location)
    //     count++
    // }
}