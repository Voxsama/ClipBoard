import AppKit
import SwiftUI

/// A borderless floating panel that behaves like Spotlight – appears centered,
/// dismisses when it loses focus, and does not steal activation from other apps.
final class FloatingPanel: NSPanel {

    init(contentView: NSView) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 520),
            styleMask: [.titled, .closable, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        self.contentView = contentView
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        isMovableByWindowBackground = true
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        animationBehavior = .utilityWindow

        self.contentView?.wantsLayer = true
        self.contentView?.layer?.cornerRadius = 12
        self.contentView?.layer?.masksToBounds = true
    }

    // MARK: - Show / Hide

    func showCentered() {
        guard let screen = NSScreen.main else { return }
        let area = screen.visibleFrame
        let size = frame.size
        let origin = NSPoint(
            x: area.midX - size.width / 2,
            y: area.midY - size.height / 2
        )
        setFrameOrigin(origin)
        makeKeyAndOrderFront(nil)

        alphaValue = 0
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.15
            animator().alphaValue = 1
        }
    }

    func hidePanel() {
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.1
            animator().alphaValue = 0
        } completionHandler: {
            self.orderOut(nil)
        }
    }

    func toggle() {
        isVisible ? hidePanel() : showCentered()
    }

    // MARK: - Behavior

    override var canBecomeKey: Bool { true }

    override func resignKey() {
        super.resignKey()
        hidePanel()
    }
}
