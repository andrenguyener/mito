package handlers

import "net/http"

//CORSHandler is an http interface struct
type CORSHandler struct {
	Handler http.Handler
}

//ServeHTTP is the handler interface
func (ch *CORSHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Access-Control-Allow-Origin", "*")
	w.Header().Add("Access-Control-Allow-Methods", "GET, PUT, POST, PATCH, DELETE")
	w.Header().Add("Access-Control-Allow-Headers", "Content-Type, Authorization")
	w.Header().Add("Access-Control-Expose-Headers", "Authorization")
	w.Header().Add("Access-Control-Max-Age", "600")
	w.Header().Add("Content-Type", "application/json")
	if r.Method == "OPTIONS" {

		w.WriteHeader(http.StatusOK)
	} else {
		ch.Handler.ServeHTTP(w, r)
	}

}

//NewCORSHandler initializes a new CorsHandlers struct
func NewCORSHandler(handlerToWrap http.Handler) *CORSHandler {
	return &CORSHandler{handlerToWrap}
}
