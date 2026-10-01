import Carbon.HIToolbox
import AppKit

/// Registers a global keyboard shortcut (⌘⇧V) using the Carbon Events API.
final class HotKeyManager {
    static let shared = HotKeyManager()

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?

    /// Called when the global shortcut is pressed.
    var onHotKeyPressed: (() -> Void)?

    private init() {}

    /// Register ⌘⇧V as the global hotkey.
    func register(
        keyCode: UInt32 = UInt32(kVK_ANSI_V),
        modifiers: UInt32 = UInt32(cmdKey | shiftKey)
    ) {
        var hotKeyID = EventHotKeyID(
            signature: FourCharCode(truncatingIfNeeded: 0x434C_4950), // "CLIP"
            id: 1
        )

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        // Install the handler – the `userData` pointer lets the C callback
        // reach back into this Swift object.
        let selfPtr = UnsafeMutableRawPointer(
            Unmanaged.passUnretained(self).toOpaque()
        )

        let installStatus = InstallEventHandler(
            GetApplicationEventTarget(),
            hotKeyEventHandler,       // C-compatible function below
            1,
            &eventType,
            selfPtr,
            &eventHandlerRef
        )
        guard installStatus == noErr else {
            print("[HotKeyManager] Failed to install event handler: \(installStatus)")
            return
        }

        let registerStatus = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        guard registerStatus == noErr else {
            print("[HotKeyManager] Failed to register hotkey: \(registerStatus)")
            return
        }

        print("[HotKeyManager] Global hotkey registered: ⌘⇧V")
    }

    func unregister() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
        if let handler = eventHandlerRef {
            RemoveEventHandler(handler)
            eventHandlerRef = nil
        }
    }

    deinit { unregister() }
}

// MARK: - C-compatible callback

/// This free function satisfies the `EventHandlerUPP` signature required by Carbon.
private func hotKeyEventHandler(
    _: EventHandlerCallRef?,
    _: EventRef?,
    userData: UnsafeMutableRawPointer?
) -> OSStatus {
    guard let userData else { return OSStatus(eventNotHandledErr) }
    let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
    DispatchQueue.main.async { manager.onHotKeyPressed?() }
    return noErr
}
