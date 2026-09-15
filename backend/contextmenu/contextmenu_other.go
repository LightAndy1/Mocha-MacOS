//go:build !windows

package contextmenu

import "errors"

func Deploy() (string, error) {
	return "", errors.New("quick share context menu is Windows only")
}

func Enable() error {
	return errors.New("quick share context menu is Windows only")
}

func Disable() error { return nil }
