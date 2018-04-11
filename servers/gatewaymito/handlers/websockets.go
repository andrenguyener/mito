package handlers

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"strconv"
	"sync"

	"github.com/gorilla/websocket"
	"github.com/mito/servers/gatewaymito/sessions"
	"github.com/streadway/amqp"
)

type WebSocketsHandler struct {
	notifier *Notifier
	upgrader *websocket.Upgrader
	ctx      *Context
}

func (ctx *Context) NewWebSocketsHandler(notifier *Notifier) *WebSocketsHandler {

	return &WebSocketsHandler{
		notifier: notifier,
		upgrader: &websocket.Upgrader{
			ReadBufferSize:  1024,
			WriteBufferSize: 1024,
			CheckOrigin:     func(r *http.Request) bool { return true },
		},
		ctx: ctx,
	}
}

func (wsh *WebSocketsHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {

	sessState := &SessionState{}
	_, err := sessions.GetState(r, wsh.ctx.SessionKey, wsh.ctx.SessionStore, sessState)
	if err != nil {
		auth := r.URL.Query().Get("auth")
		if auth == "" {
			http.Error(w, "status unauthorized", http.StatusUnauthorized)
			return
		}
		r.Header.Del("X-User")

	}

	log.Println("received websocket upgrade request")
	conn, err := wsh.upgrader.Upgrade(w, r, nil)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error connecting to websocket: %v", err), http.StatusInternalServerError)
		return
	}
	wsh.notifier.AddClient(conn, sessState.User.UserId)
}

type Connection struct {
	userID int
	conn   *websocket.Conn
}

type Notifier struct {
	clients []Connection
	eventQ  <-chan amqp.Delivery
	mx      sync.RWMutex
}

func NewNotifier(evt <-chan amqp.Delivery) *Notifier {
	notifier := &Notifier{
		clients: []Connection{},
		eventQ:  evt,
	}

	go notifier.start()
	return notifier
}

func (n *Notifier) AddClient(client *websocket.Conn, userId int) {
	n.mx.Lock()
	userConnection := Connection{
		conn:   client,
		userID: userId,
	}
	n.clients = append(n.clients, userConnection)
	n.mx.Unlock()
	sliceClients := []Connection{}

	for {
		// if there is an error (user disconnects)
		// removes the disconnected client from the slice
		_, r, err := client.NextReader()
		if err != nil {
			client.Close()
			n.mx.Lock()

			for i := range n.clients {
				if (n.clients[i].conn) == client {
					sliceClients = append(n.clients[:i], n.clients[i+1:]...)
				}
			}
			n.clients = sliceClients
			n.mx.Unlock()
			break
		}

		userBytes, err := ioutil.ReadAll(r)
		if err != nil {
			fmt.Printf("Error: %v", err)
		}
		userString := string(userBytes[:])
		userInt, err := strconv.Atoi(userString)
		if err != nil {
			fmt.Printf("Error: %v", err)
		}
		for i := range n.clients {
			if (n.clients[i].conn) == client {
				n.clients[i].userID = userInt
				break
			}
		}

		fmt.Printf("user string: %v", userString)
	}
}

type userID struct {
	UserID    int    `json:"userIdOut"`
	EventType string `json:"type"`
	EventData string `json:"friend"`
}

func (n *Notifier) start() {
	for {
		event := <-n.eventQ
		n.mx.RLock()
		// log.Printf("clients: %v", n.clients)
		// log.Printf("Event: %v", event)
		// log.Printf("Event Body: %v", event.Body)
		userDoc := &userID{}

		err := json.Unmarshal(event.Body, &userDoc)
		if err != nil {
			fmt.Println(err)
		}
		// no := string(event.Body[:])
		// log.Printf("String Event: %v", no)
		log.Println(userDoc)

		for _, client := range n.clients {
			if userDoc.UserID == client.userID {
				log.Println(event.Body)
				err := client.conn.WriteMessage(websocket.TextMessage, event.Body)
				if err != nil {
					log.Printf("Error: %v", err)
				}
			}

		}
		n.mx.RUnlock()
	}
}
