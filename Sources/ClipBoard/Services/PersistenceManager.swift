import Foundation

/// Handles saving and loading clipboard history to disk.
final class PersistenceManager {
    static let shared = PersistenceManager()

    private let fileManager = FileManager.default
    private let historyFileName = "clipboard_history.json"

    /// Root directory inside ~/Library/Application Support/ClipBoard.
    var storageDirectory: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("ClipBoard", isDirectory: true)
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    /// Sub-directory for stored images.
    var imagesDirectory: URL {
        let dir = storageDirectory.appendingPathComponent("Images", isDirectory: true)
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private var historyFileURL: URL {
        storageDirectory.appendingPathComponent(historyFileName)
    }

    // MARK: - History

    func saveItems(_ items: [ClipboardItem]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(items) else { return }
        try? data.write(to: historyFileURL, options: .atomic)
    }

    func loadItems() -> [ClipboardItem] {
        guard let data = try? Data(contentsOf: historyFileURL) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([ClipboardItem].self, from: data)) ?? []
    }

    // MARK: - Images

    func saveImageData(_ data: Data, fileName: String) {
        let url = imagesDirectory.appendingPathComponent(fileName)
        try? data.write(to: url, options: .atomic)
    }

    func loadImageData(fileName: String) -> Data? {
        let url = imagesDirectory.appendingPathComponent(fileName)
        return try? Data(contentsOf: url)
    }

    func deleteImageFile(fileName: String) {
        let url = imagesDirectory.appendingPathComponent(fileName)
        try? fileManager.removeItem(at: url)
    }

    func clearAllImages() {
        try? fileManager.removeItem(at: imagesDirectory)
        try? fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
    }
}
