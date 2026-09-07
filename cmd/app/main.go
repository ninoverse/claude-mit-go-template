// Command app is a placeholder binary. The Dockerfile builds this path, so it
// has to exist for `docker build` to work on a fresh clone. Point both at your
// own binary and delete this one.
package main

import (
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/ninoverse/claude-mit-go-template/internal/greet"
)

func main() {
	// Cloud Run injects PORT. Defaulting keeps `go run ./cmd/app` working.
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if _, err := fmt.Fprintln(w, greet.Greet(r.URL.Query().Get("name"))); err != nil {
			log.Printf("write response: %v", err)
		}
	})

	// Explicit timeouts rather than http.ListenAndServe: the zero-value server
	// has none, so one slow client can hold a connection open indefinitely.
	srv := &http.Server{
		Addr:              ":" + port,
		Handler:           mux,
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       15 * time.Second,
		WriteTimeout:      15 * time.Second,
		IdleTimeout:       60 * time.Second,
	}

	log.Printf("listening on %s", srv.Addr)
	if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
		log.Fatalf("server: %v", err)
	}
}
