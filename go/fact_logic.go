//go:build windows

package main

import (
	"C"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"syscall"
	"unsafe"

	"github.com/gonutz/w32/v2"
)
import "time"

const (
	saveDir    = `AppData\Local\FactoryGame\Saved\SaveGames`
	desktopDir = `Desktop`
)

func buildPath(pathEnd string) (string, error) {
	profile := os.Getenv("USERPROFILE")
	if profile == "" {
		return "", fmt.Errorf("$USERPROFILE not set")
	}
	fullPath := filepath.Join(profile, pathEnd)
	return fullPath, nil
}

func mostRecent(root string, isDir bool) (string, error) {
	entries, err := os.ReadDir(root)
	if err != nil {
		return "", err
	}

	var bestName string
	var bestTime time.Time

	for _, entry := range entries {
		if entry.IsDir() != isDir {
			continue
		}

		if entry.Name() == "common" {
			continue
		}

		info, err := entry.Info()
		if err != nil {
			continue
		}

		if info.ModTime().After(bestTime) {
			bestTime = info.ModTime()
			bestName = entry.Name()
		}
	}

	if bestName == "" {
		return "", fmt.Errorf("no matching %s found in %s",
			map[bool]string{true: "directory", false: "file"}[isDir], root)
	}

	return bestName, nil
}

func copyFile(src, dst string) error {
	sourceFile, err := os.Open(src)
	if err != nil {
		return fmt.Errorf("failed to open source file: %w", err)
	}
	defer sourceFile.Close()

	destinationFile, err := os.Create(dst)
	if err != nil {
		return fmt.Errorf("failed to create destination file: %w", err)
	}
	defer destinationFile.Close()

	_, err = io.Copy(destinationFile, sourceFile)
	if err != nil {
		return fmt.Errorf("failed to copy file: %w", err)
	}

	err = destinationFile.Sync()
	if err != nil {
		return fmt.Errorf("failed to sync destination file: %w", err)
	}

	return nil
}

func getLatestSavePath() (string, error) {
	base, err := buildPath(saveDir)
	if err != nil {
		return "", err
	}

	userFolder, err := mostRecent(base, true)
	if err != nil {
		return "", err
	}

	fullFolderPath := filepath.Join(base, userFolder)

	saveFile, err := mostRecent(fullFolderPath, false)
	if err != nil {
		return "", err
	}

	return filepath.Join(fullFolderPath, saveFile), nil
}

type DROPFILES struct {
	PFiles uint32
	Pt     struct{ X, Y int32 }
	FNC    int32
	FWide  int32
}

func CopyToClipboardFunc() error {
	savePath, err := getLatestSavePath()
	if err != nil {
		return err
	}

	// 1. Convert path to UTF16 (Windows standard) and add a double null terminator
	pathPtr, _ := syscall.UTF16FromString(savePath)
	pathPtr = append(pathPtr, 0) // Windows needs an extra null to end the list
	pathSize := len(pathPtr) * 2

	// 2. Open the Clipboard
	if !w32.OpenClipboard(0) {
		return fmt.Errorf("could not open clipboard")
	}
	defer w32.CloseClipboard()
	w32.EmptyClipboard()

	// 3. Allocate global memory for the DROPFILES struct + the path string
	hMem := w32.GlobalAlloc(w32.GMEM_MOVEABLE, uint32(unsafe.Sizeof(DROPFILES{})+uintptr(pathSize)))
	ptr := w32.GlobalLock(hMem)

	// 4. Set up the DROPFILES header
	df := (*DROPFILES)(ptr)
	df.PFiles = uint32(unsafe.Sizeof(DROPFILES{}))
	df.FWide = 1 // Signal that we are using UTF-16 (Wide chars)

	// 5. Copy the path data into the memory after the header
	dest := unsafe.Pointer(uintptr(ptr) + uintptr(df.PFiles))
	copy((*[1 << 20]uint16)(dest)[:len(pathPtr)], pathPtr)

	w32.GlobalUnlock(hMem)

	// 6. Set the clipboard data as a "File Drop" (CF_HDROP)
	if w32.SetClipboardData(w32.CF_HDROP, w32.HANDLE(hMem)) == 0 {
		return fmt.Errorf("failed to set clipboard data")
	}

	return nil
}

func CopyToDesktopFunc() error {
	src, err := getLatestSavePath()
	if err != nil {
		return err
	}

	desk, err := buildPath(desktopDir)
	if err != nil {
		return err
	}

	dst := filepath.Join(desk, filepath.Base(src))
	return copyFile(src, dst)
}

//export CopyToDesktop
func CopyToDesktop() {
	err := CopyToDesktopFunc()
	if err != nil {
		fmt.Printf("Go Error: %v\n", err)
	}
}

//export CopyToClipboard
func CopyToClipboard() {
	err := CopyToClipboardFunc()
	if err != nil {
		fmt.Printf("Go Error: %v\n", err)
	}
}

func main() {}
