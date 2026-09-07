// Package greet is a placeholder so the module is not empty.
//
// A module with no packages does not merely build to nothing: `go vet ./...`
// and `go test ./...` both exit 1 with "no packages to vet", so gates 2 and 3
// are red on a fresh clone without it. Delete this package once you have added
// a real one.
package greet

import "fmt"

// Greet returns a greeting for name, or for the world if name is empty.
func Greet(name string) string {
	if name == "" {
		name = "world"
	}
	return fmt.Sprintf("hello, %s", name)
}
