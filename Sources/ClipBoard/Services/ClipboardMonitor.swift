import Foundation
import AppKit

/// Polls the system pasteboard for changes and creates `ClipboardItem` entries.
final class ClipboardMonitor {
    private var timer: Timer?
    private var lastChangeCount: Int = 0

    /// Called on the main thread when a new item is detected.
    var onNewItem: ((ClipboardItem) -> Void)?

    func startMonitoring() {
        lastChangeCount = NSPasteboard.general.changeCount
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkForChanges()
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Private

    private func checkForChanges() {
        let pasteboard = NSPasteboard.general
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        let frontApp = NSWorkspace.shared.frontmostApplication
        let appName = frontApp?.localizedName
        let bundleID = frontApp?.bundleIdentifier

        if let item = readPasteboardContent(appName: appName, bundleID: bundleID) {
            DispatchQueue.main.async { self.onNewItem?(item) }
        }
    }

    private func readPasteboardContent(appName: String?, bundleID: String?) -> ClipboardItem? {
        let pb = NSPasteboard.general

        // 1) Files
        if let urls = pb.readObjects(forClasses: [NSURL.self],
                                     options: [.urlReadingFileURLsOnly: true]) as? [URL],
           !urls.isEmpty {
            return ClipboardItem(
                id: UUID(), type: .file, textContent: nil,
                imageFileName: nil, fileURLs: urls.map(\.path),
                sourceAppName: appName, sourceAppBundleID: bundleID,
                createdAt: Date(), isPinned: false)
        }

        // 2) Images
        if let imgData = pb.data(forType: .tiff) ?? pb.data(forType: .png) {
            let fileName = UUID().uuidString + ".png"
            if let image = NSImage(data: imgData),
               let tiff = image.tiffRepresentation,
               let rep = NSBitmapImageRep(data: tiff),
               let png = rep.representation(using: .png, properties: [:]) {
                PersistenceManager.shared.saveImageData(png, fileName: fileName)
            }
            return ClipboardItem(
                id: UUID(), type: .image, textContent: nil,
                imageFileName: fileName, fileURLs: nil,
                sourceAppName: appName, sourceAppBundleID: bundleID,
                createdAt: Date(), isPinned: false)
        }

        // 3) Text (may be a URL)
        if let text = pb.string(forType: .string), !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            let isURL = trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://")
            let words = text.split(whereSeparator: \.isWhitespace).count
            return ClipboardItem(
                id: UUID(), type: isURL ? .url : .text,
                textContent: text, imageFileName: nil, fileURLs: nil,
                sourceAppName: appName, sourceAppBundleID: bundleID,
                createdAt: Date(), isPinned: false,
                characterCount: text.count, wordCount: words)
        }

        return nil
    }
}
