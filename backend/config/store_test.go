package config

import "testing"

func TestContextMenuRoundTrip(t *testing.T) {
	dir := t.TempDir()
	t.Setenv("AppData", dir)
	t.Setenv("XDG_CONFIG_HOME", dir)
	t.Setenv("HOME", dir)
	if orig, err := Dir(); err != nil || orig == "" {
		t.Fatalf("Dir: %v", err)
	}
	s := Store{SyncFolders: []string{}}
	s.Settings.ContextMenuEnabled = true
	if err := Save(s); err != nil {
		t.Fatalf("Save: %v", err)
	}
	loaded, err := Load()
	if err != nil {
		t.Fatalf("Load: %v", err)
	}
	if !loaded.Settings.ContextMenuEnabled {
		t.Fatal("ContextMenuEnabled not persisted")
	}
}
