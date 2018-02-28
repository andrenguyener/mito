package handlers

import (
	"fmt"
	"log"
	"net/http"
	"sync"

	"github.com/andrenguyener/mito/servers/gatewaymito/sessions"
	"github.com/gorilla/websocket"
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

	sessState := SessionState{}
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
	go wsh.notifier.AddClient(conn)
}

type Notifier struct {
	clients []*websocket.Conn
	eventQ  <-chan amqp.Delivery
	mx      sync.RWMutex
}

func NewNotifier(evt <-chan amqp.Delivery) *Notifier {
	notifier := &Notifier{
		clients: []*websocket.Conn{},
		eventQ:  evt,
	}

	go notifier.start()
	return notifier
}

func (n *Notifier) AddClient(client *websocket.Conn) {
	n.mx.Lock()
	n.clients = append(n.clients, client)
	n.mx.Unlock()
	sliceClients := []*websocket.Conn{}
	for {
		// if there is an error (user disconnects)
		// removes the disconnected client from the slice
		if _, _, err := client.NextReader(); err != nil {
			client.Close()
			n.mx.Lock()
			for i := range n.clients {
				if (n.clients[i]) != client {
					sliceClients = append(sliceClients, n.clients[i])
				}
			}
			n.clients = sliceClients
			n.mx.Unlock()
			break
		}
	}
}

func (n *Notifier) start() {
	for {
		event := <-n.eventQ
		n.mx.RLock()
		log.Println(n.clients)
		for _, client := range n.clients {
			err := client.WriteMessage(websocket.TextMessage, event.Body)
			if err != nil {
				log.Printf("Error: %v", err)
			}
		}
		n.mx.RUnlock()
	}
}
