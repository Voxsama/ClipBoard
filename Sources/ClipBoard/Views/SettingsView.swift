import SwiftUI

/// Preferences window accessible via the app menu → Settings.
struct SettingsView: View {
    @AppStorage("maxHistorySize") private var maxHistorySize = 100
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("playSoundOnCopy") private var playSoundOnCopy = false

    var body: some View {
        TabView {
            generalTab
                .tabItem { Label("General", systemImage: "gear") }
            storageTab
                .tabItem { Label("Storage", systemImage: "internaldrive") }
            shortcutTab
                .tabItem { Label("Shortcuts", systemImage: "keyboard") }
            aboutTab
                .tabItem { Label("About", systemImage: "info.circle") }
        }
        .frame(width: 450, height: 300)
    }

    // MARK: - Tabs

    private var generalTab: some View {
        Form {
            Toggle("Launch at Login", isOn: $launchAtLogin)
            Toggle("Play Sound on Copy", isOn: $playSoundOnCopy)
        }
        .padding(20)
    }

    private var storageTab: some View {
        Form {
            Picker("Max History Size", selection: $maxHistorySize) {
                Text("25 items").tag(25)
                Text("50 items").tag(50)
                Text("100 items").tag(100)
                Text("250 items").tag(250)
                Text("500 items").tag(500)
            }

            HStack {
                Text("Storage Location")
                Spacer()
                Text(PersistenceManager.shared.storageDirectory.path)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Button("Reveal") {
                    NSWorkspace.shared.selectFile(
                        nil,
                        inFileViewerRootedAtPath: PersistenceManager.shared.storageDirectory.path
                    )
                }
            }
        }
        .padding(20)
    }

    private var shortcutTab: some View {
        Form {
            HStack {
                Text("Toggle Clipboard")
                Spacer()
                Text("⌘ ⇧ V")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(6)
            }
        }
        .padding(20)
    }

    private var aboutTab: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.on.clipboard.fill")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            Text("ClipBoard")
                .font(.title2).fontWeight(.bold)
            Text("Version 1.0.0")
                .font(.caption).foregroundColor(.secondary)
            Text("A native clipboard manager for macOS")
                .font(.caption).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
