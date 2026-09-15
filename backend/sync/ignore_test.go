package sync

import "testing"

func TestMatchIgnore(t *testing.T) {
	pats := append([]string{}, DefaultIgnores...)
	cases := []struct {
		rel  string
		want bool
	}{
		{".git/config", true},
		{"sub/node_modules/pkg/index.js", true},
		{".DS_Store", true},
		{"photos/img.jpg", false},
		{"~$doc.xlsx", true},
		{"a.tmp", true},
		{"file.mocha-part", true},
		{"keep.txt", false},
	}
	for _, c := range cases {
		if got := MatchIgnore(c.rel, pats); got != c.want {
			t.Errorf("MatchIgnore(%q) = %v, want %v", c.rel, got, c.want)
		}
	}
	if !MatchIgnore("build/out.js", []string{"build/"}) {
		t.Errorf("dir pattern should match")
	}
	if MatchIgnore("build2/out.js", []string{"build/"}) {
		t.Errorf("dir pattern should not match sibling")
	}
}
