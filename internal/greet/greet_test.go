package greet

import "testing"

func TestGreet(t *testing.T) {
	t.Parallel()

	cases := map[string]struct {
		in   string
		want string
	}{
		"named": {in: "go", want: "hello, go"},
		"empty": {in: "", want: "hello, world"},
	}

	for name, tc := range cases {
		t.Run(name, func(t *testing.T) {
			t.Parallel()

			if got := Greet(tc.in); got != tc.want {
				t.Errorf("Greet(%q) = %q, want %q", tc.in, got, tc.want)
			}
		})
	}
}
