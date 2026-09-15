package auth

import (
	"errors"
	"os"
	"path/filepath"
	goruntime "runtime"
	"strings"

	"mocha-desktop/backend/config"

	"github.com/zalando/go-keyring"
)

const service = "mocha-desktop"
const account = "api-key"

func hint(err error) error {
	if err == nil {
		return nil
	}
	switch goruntime.GOOS {
	case "linux":
		return errors.New(err.Error() + " (needs a Secret Service keyring such as gnome-keyring running on the session bus)")
	case "darwin":
		return errors.New(err.Error() + " (macOS Keychain denied access; allow Mocha Desktop in Keychain Access)")
	default:
		return err
	}
}

func keyFile() string {
	dir, err := config.Dir()
	if err != nil {
		return ""
	}
	return filepath.Join(dir, "api-key")
}

func SaveKey(key string) error {
	if key == "" {
		return errors.New("empty api key")
	}
	if err := keyring.Set(service, account, key); err == nil {
		_ = os.Remove(keyFile())
		return nil
	}
	p := keyFile()
	if p == "" {
		return hint(errors.New("keyring unavailable"))
	}
	if err := os.WriteFile(p, []byte(strings.TrimSpace(key)), 0o600); err != nil {
		return hint(err)
	}
	return nil
}

func LoadKey() (string, error) {
	key, err := keyring.Get(service, account)
	if err == nil && strings.TrimSpace(key) != "" {
		return key, nil
	}
	p := keyFile()
	if p != "" {
		if raw, ferr := os.ReadFile(p); ferr == nil {
			if k := strings.TrimSpace(string(raw)); k != "" {
				return k, nil
			}
		}
	}
	if err != nil {
		return "", hint(err)
	}
	return "", hint(errors.New("no api key"))
}

func ClearKey() error {
	_ = os.Remove(keyFile())
	return hint(keyring.Delete(service, account))
}
