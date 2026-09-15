package contextmenu

import goruntime "runtime"

func Supported() bool {
	return goruntime.GOOS == "windows"
}
