# ClipBoard 📋

A native macOS clipboard manager — like **Windows Win+V**, but with a macOS-native look and feel.

![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue)
![Swift 5.9+](https://img.shields.io/badge/Swift-5.9%2B-orange)

## Features

- **⌘⇧V** global shortcut to open the clipboard panel (just like Win+V)
- **Menu bar icon** for quick access
- **Clipboard history** — text, images, files, and URLs
- **Search** across all clipboard entries
- **Pin favorites** so they never get pushed out
- **Click to re-copy** any past item
- **Source app tracking** — see where each copy came from
- **Persistent storage** — history survives app restarts
- **Native macOS design** — vibrancy, smooth animations, rounded corners
- **No Dock icon** — lives quietly in your menu bar

## Requirements

- macOS 13 (Ventura) or later
- Xcode 15+ or Swift 5.9+ toolchain

## Build & Run

### Option 1: Command Line (Swift Package Manager)

```bash
# Clone or copy the project, then:
cd ClipBoard
./build.sh

# Launch
open ClipBoard.app

# Or install to Applications
cp -R ClipBoard.app /Applications/
```

### Option 2: Xcode

1. Open Xcode
2. **File → New → Project → macOS → App** (or open Terminal in the project folder and run `open Package.swift`)
3. Xcode will resolve the Swift Package automatically
4. Press **⌘R** to build and run

## Usage

| Action | How |
|---|---|
| Open clipboard panel | Press **⌘⇧V** or click the menu bar icon |
| Copy an item | Click on it in the list |
| Pin an item | Right-click → Pin, or hover and click the pin icon |
| Delete an item | Right-click → Delete, or hover and click the trash icon |
| Search | Type in the search bar at the top |
| Filter by type | Click the filter chips (All / Text / Image / File / Link) |
| Clear history | Click "Clear All" in the footer (pinned items are kept) |
| Open Settings | Right-click the menu bar icon, or use the app menu |

## Permissions

On first launch, macOS will prompt you to grant **Accessibility** permission:

> **System Settings → Privacy & Security → Accessibility → ClipBoard ✅**

This is required for the ⌘⇧V global keyboard shortcut to work.

## Architecture

```
Sources/ClipBoard/
├── ClipBoardApp.swift          # @main entry point
├── AppDelegate.swift           # Status bar, panel, and hotkey setup
├── Models/
│   └── ClipboardItem.swift     # Data model for clipboard entries
├── ViewModels/
│   └── ClipboardViewModel.swift # History management, search, filtering
├── Services/
│   ├── ClipboardMonitor.swift  # Polls NSPasteboard for changes
│   └── PersistenceManager.swift # JSON + image file storage
├── Views/
│   ├── ClipboardPopoverView.swift # Main floating panel UI
│   ├── ClipboardItemRow.swift     # Individual item row
│   └── SettingsView.swift         # Preferences window
└── Helpers/
    ├── HotKeyManager.swift     # Carbon API global hotkey
    └── FloatingPanel.swift     # NSPanel subclass
```

## How It Works

1. **ClipboardMonitor** polls `NSPasteboard.general.changeCount` every 500ms
2. When a change is detected, it reads the pasteboard content (text, image, file, or URL)
3. A `ClipboardItem` is created and added to the history
4. Items are persisted to `~/Library/Application Support/ClipBoard/` as JSON (with images as PNG files)
5. The **FloatingPanel** renders the SwiftUI views with native vibrancy
6. **HotKeyManager** uses the Carbon Events API to register ⌘⇧V globally

## Settings

- **Max history size** — 25 / 50 / 100 / 250 / 500 items
- **Launch at Login** — start automatically
- **Sound on Copy** — audible feedback

## License

MIT — use it however you like.
