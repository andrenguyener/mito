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

	"github.com/andrenguyener/mito/servers/gatewaymito/models/users"
	"github.com/andrenguyener/mito/servers/gatewaymito/sessions"
	"github.com/streadway/amqp"

	"context"
	"database/sql"

	"github.com/andrenguyener/mito/servers/gatewaymito/handlers"
	_ "github.com/denisenkom/go-mssqldb"
	"github.com/go-redis/redis"
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
	redisStore := sessions.NewRedisStore(redisClient, time.Hour)

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
	// tlskey := "./../tls/privkey.pem"
	tlscert := os.Getenv("TLSCERT")
	// tlscert := "./../tls/fullchain.pem"
	if len(tlskey) == 0 || len(tlscert) == 0 {
		log.Fatal("please set TLSKEY and TLSCERT")
	}

	splitMitoNodeAddrs := strings.Split(mitoNodeaddr, ",")
	// splitSummaryAddrs := strings.Split(summaryaddr, ",")

	mux := http.NewServeMux()
	mux.HandleFunc("/v1/users", ctx.UsersHandler)
	mux.HandleFunc("/v1/users/me", ctx.UsersMeHandler)
	mux.HandleFunc("/v1/users/id", ctx.UsersIDHandler)
	mux.HandleFunc("/v1/sessions", ctx.SessionsHandler)
	mux.HandleFunc("/v1/sessions/mine", ctx.SessionsMineHandler)

	corsHandler := handlers.NewCORSHandler(mux)
	mux.Handle("/v1/ws", ctx.NewWebSocketsHandler(notifier))
	fmt.Printf("server is listening at https://%s\n", addr)

	// mux.Handle("/v1/channels", NewServiceProxy(splitMitoNodeAddrs, ctx))
	// mux.Handle("/v1/channels/", NewServiceProxy(splitMitoNodeAddrs, ctx))
	// mux.Handle("/v1/messages/", NewServiceProxy(splitMitoNodeAddrs, ctx))
	// mux.Handle("/v1/summary", NewServiceProxy(splitSummaryAddrs, ctx))
	// mux.Handle("/v1/payments", NewServiceProxy(splitMitoNodeAddrs, ctx))
	// mux.Handle("/v1/payments/", NewServiceProxy(splitMitoNodeAddrs, ctx))
	// mux.Handle("/v1/email", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/address", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/address/", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/friend", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/friend/", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/amazonhash/", NewServiceProxy(splitMitoNodeAddrs, ctx))
	mux.Handle("/v1/amazonsearch", NewServiceProxy(splitMitoNodeAddrs, ctx))
	log.Fatal(http.ListenAndServeTLS(addr, tlscert, tlskey, corsHandler))
}

type User struct {
	UserId       int
	UserFName    string
	UserLName    string
	UserEmail    string
	PasswordHash string
	PhotoUrl     sql.NullString
	UserDOB      string
	Username     string
}

// Gets and prints SQL Server version
func SelectVersion() {
	// Use background context
	ctx := context.Background()

	// Ping database to see if it's still alive.
	// Important for handling network issues and long queries.
	err := db.PingContext(ctx)
	if err != nil {
		log.Fatal("Error pinging database: " + err.Error())
	}

	rows, err := db.Query("SELECT * FROM [projectmito].[dbo].[USER]")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()
	cols, _ := rows.Columns()
	fmt.Println(cols)
	for rows.Next() {
		var name User

		if err := rows.Scan(&name.UserId, &name.UserFName, &name.UserLName, &name.UserEmail, &name.PasswordHash, &name.PhotoUrl, &name.UserDOB, &name.Username); err != nil {
			log.Fatal(err)
		}
		fmt.Println(name)
	}
	if err := rows.Err(); err != nil {
		log.Fatal(err)
	}
	//UserId UserFname UserLname UserEmail PasswordHash PhotoUrl UserDOB Username
	// tsql := fmt.Sprintf("INSERT INTO [projectmito].[dbo].[USER] (UserFname, UserLname, UserEmail, PasswordHash, PhotoUrl, UserDOB, Username) VALUES (@UserFname, @UserLname, @UserEmail, @PasswordHash, @PhotoUrl, @UserDOB, @Username);")
	tsql := fmt.Sprintf("EXEC insertUser @UserFname, @UserLname, @UserEmail, @PasswordHash, @PhotoUrl, @UserDOB, @Username;")

	// Execute non-query with named parameters
	_, err = db.Exec(
		tsql,
		sql.Named("UserFname", "Tom2"),
		sql.Named("UserLname", "Brady2"),
		sql.Named("UserEmail", "Tom@uw.edu2"),
		sql.Named("PasswordHash", []byte("wahid2")),
		sql.Named("PhotoUrl", "Tom@pictureurl2"),
		sql.Named("UserDOB", "1995-01-02T00:00:00Z"),
		sql.Named("Username", "Tom2"))

	if err != nil {
		log.Fatal("Error inserting new row: " + err.Error())
	}
	fmt.Println("QUERY AGAIN AFTER INSTERTING")
	// Query again after inserting
	rows, err = db.Query("SELECT * FROM [projectmito].[dbo].[USER]")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()
	cols, _ = rows.Columns()
	fmt.Println(cols)
	for rows.Next() {
		var name User

		if err := rows.Scan(&name.UserId, &name.UserFName, &name.UserLName, &name.UserEmail, &name.PasswordHash, &name.PhotoUrl, &name.UserDOB, &name.Username); err != nil {
			log.Fatal(err)
		}
		fmt.Println(name)
	}
	if err := rows.Err(); err != nil {
		log.Fatal(err)
	}

	tsql = fmt.Sprintf("DELETE FROM [projectmito].[dbo].[USER] WHERE UserFname=@UserFname;")

	// Execute non-query with named parameters
	_, err = db.ExecContext(ctx, tsql, sql.Named("UserFname", "Tom"))
	if err != nil {
		fmt.Println("Error deleting row: " + err.Error())
	}
	fmt.Println("QUERY AGAIN AFTER DELETE")
	// query again after deleting
	rows, err = db.Query("SELECT * FROM [projectmito].[dbo].[USER]")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()
	cols, _ = rows.Columns()
	fmt.Println(cols)
	for rows.Next() {
		var name User

		if err := rows.Scan(&name.UserId, &name.UserFName, &name.UserLName, &name.UserEmail, &name.PasswordHash, &name.PhotoUrl, &name.UserDOB, &name.Username); err != nil {
			log.Fatal(err)
		}
		fmt.Println(name)
	}
	if err := rows.Err(); err != nil {
		log.Fatal(err)
	}

	tsql = fmt.Sprintf("UPDATE [projectmito].[dbo].[USER] SET UserFname = @newName WHERE UserFname= @Name")

	// Execute non-query with named parameters
	_, err = db.ExecContext(
		ctx,
		tsql,
		sql.Named("newName", "Victoria"),
		sql.Named("Name", "Victor"))
	if err != nil {
		log.Fatal("Error updating row: " + err.Error())
	}

	fmt.Println("QUERY AGAIN AFTER UPDATING")
	// Query again after inserting
	rows, err = db.Query("SELECT * FROM [projectmito].[dbo].[USER]")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()
	cols, _ = rows.Columns()
	fmt.Println(cols)
	for rows.Next() {
		var name User

		if err := rows.Scan(&name.UserId, &name.UserFName, &name.UserLName, &name.UserEmail, &name.PasswordHash, &name.PhotoUrl, &name.UserDOB, &name.Username); err != nil {
			log.Fatal(err)
		}
		fmt.Println(name)
	}
	if err := rows.Err(); err != nil {
		log.Fatal(err)
	}
}
