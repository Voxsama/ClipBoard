import SwiftUI

/// The main entry point. The real setup happens in `AppDelegate`;
/// this `App` struct only provides the Settings scene.
@main
struct ClipBoardApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}
