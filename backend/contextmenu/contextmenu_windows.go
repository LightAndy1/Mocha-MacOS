//go:build windows

package contextmenu

import (
	_ "embed"
	"os"
	"path/filepath"

	"mocha-desktop/backend/config"

	"golang.org/x/sys/windows/registry"
)

//go:embed quickshare.ps1
var Script []byte

func Deploy() (string, error) {
	dir, err := config.Dir()
	if err != nil {
		return "", err
	}
	path := filepath.Join(dir, "quick-share.ps1")
	if err := os.WriteFile(path, Script, 0o644); err != nil {
		return "", err
	}
	return path, nil
}

const keyPath = `Software\Classes\*\shell\QuickShare`
const verbName = "Quick Share (Mocha)"
const iconValue = `%SystemRoot%\System32\shell32.dll,134`

func Enable() error {
	path, err := Deploy()
	if err != nil {
		return err
	}
	command := `powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "` + path + `" "%1"`
	key, _, err := registry.CreateKey(registry.CURRENT_USER, keyPath, registry.SET_VALUE)
	if err != nil {
		return err
	}
	defer key.Close()
	if err := key.SetStringValue("", verbName); err != nil {
		return err
	}
	if err := key.SetStringValue("Icon", iconValue); err != nil {
		return err
	}
	cmd, _, err := registry.CreateKey(registry.CURRENT_USER, keyPath+`\command`, registry.SET_VALUE)
	if err != nil {
		return err
	}
	defer cmd.Close()
	return cmd.SetStringValue("", command)
}

func Disable() error {
	if err := registry.DeleteKey(registry.CURRENT_USER, keyPath+`\command`); err != nil {
		return err
	}
	return registry.DeleteKey(registry.CURRENT_USER, keyPath)
}
