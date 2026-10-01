import AppKit
import SwiftUI

/// Sets up the status-bar item, the floating panel, and the global hotkey.
final class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem?
    private var floatingPanel: FloatingPanel?
    private let viewModel = ClipboardViewModel()

    // MARK: - Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupFloatingPanel()
        setupHotKey()

        // Run as a menu-bar-only app (no Dock icon).
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationWillTerminate(_ notification: Notification) {
        HotKeyManager.shared.unregister()
    }

    // MARK: - Status Bar

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let button = statusItem?.button else { return }
        button.image = NSImage(
            systemSymbolName: "doc.on.clipboard",
            accessibilityDescription: "ClipBoard"
        )
        button.action = #selector(statusItemClicked)
        button.target = self
    }

    @objc private func statusItemClicked() {
        togglePanel()
    }

    // MARK: - Floating Panel

    private func setupFloatingPanel() {
        let swiftUIView = ClipboardPopoverView(viewModel: viewModel)
        let hosting = NSHostingView(rootView: swiftUIView)
        floatingPanel = FloatingPanel(contentView: hosting)
    }

    // MARK: - Hot Key

    private func setupHotKey() {
        HotKeyManager.shared.onHotKeyPressed = { [weak self] in
            self?.togglePanel()
        }
        HotKeyManager.shared.register()
    }

    // MARK: - Toggle

    private func togglePanel() {
        floatingPanel?.toggle()
    }
}
