import Foundation
import AppKit
import Combine

/// Central view-model that owns the clipboard history, drives the monitor,
/// and persists items to disk.
final class ClipboardViewModel: ObservableObject {

    // MARK: - Published State

    @Published var items: [ClipboardItem] = []
    @Published var searchText: String = ""
    @Published var selectedFilter: ClipboardItemType? = nil
    @Published var maxHistorySize: Int = 100

    // MARK: - Private

    private let monitor = ClipboardMonitor()
    private let persistence = PersistenceManager.shared
    private var cancellables = Set<AnyCancellable>()
    /// Guard flag so we don't re-capture items we just placed on the pasteboard.
    private var isSettingClipboard = false

    // MARK: - Computed

    var filteredItems: [ClipboardItem] {
        var result = items

        if let filter = selectedFilter {
            result = result.filter { $0.type == filter }
        }

        if !searchText.isEmpty {
            result = result.filter { item in
                item.displayText.localizedCaseInsensitiveContains(searchText)
                || (item.sourceAppName?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        // Pinned items float to the top; otherwise newest first.
        return result.sorted { lhs, rhs in
            if lhs.isPinned != rhs.isPinned { return lhs.isPinned }
            return lhs.createdAt > rhs.createdAt
        }
    }

    var pinnedCount: Int { items.filter(\.isPinned).count }

    // MARK: - Init

    init() {
        loadHistory()
        setupMonitor()
        setupAutoSave()
    }

    // MARK: - Setup

    private func setupMonitor() {
        monitor.onNewItem = { [weak self] item in
            guard let self, !isSettingClipboard else { return }
            addItem(item)
        }
        monitor.startMonitoring()
    }

    private func setupAutoSave() {
        $items
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] items in self?.persistence.saveItems(items) }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    func addItem(_ item: ClipboardItem) {
        // De-duplicate identical text (keep pinned entries).
        if let text = item.textContent {
            items.removeAll { !$0.isPinned && $0.textContent == text }
        }
        items.insert(item, at: 0)
        trimHistory()
    }

    func copyToClipboard(_ item: ClipboardItem) {
        isSettingClipboard = true
        let pb = NSPasteboard.general
        pb.clearContents()

        switch item.type {
        case .text, .url:
            if let text = item.textContent { pb.setString(text, forType: .string) }
        case .image:
            if let name = item.imageFileName,
               let data = persistence.loadImageData(fileName: name) {
                pb.setData(data, forType: .png)
            }
        case .file:
            if let paths = item.fileURLs {
                let urls = paths.compactMap { URL(fileURLWithPath: $0) as NSURL }
                pb.writeObjects(urls)
            }
        }

        // Re-enable monitoring after the pasteboard settles.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.isSettingClipboard = false
        }
    }

    func togglePin(_ item: ClipboardItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx].isPinned.toggle()
    }

    func deleteItem(_ item: ClipboardItem) {
        if let name = item.imageFileName {
            persistence.deleteImageFile(fileName: name)
        }
        items.removeAll { $0.id == item.id }
    }

    func clearAll() {
        for item in items where !item.isPinned {
            if let name = item.imageFileName {
                persistence.deleteImageFile(fileName: name)
            }
        }
        items = items.filter(\.isPinned)
    }

    // MARK: - Helpers

    private func trimHistory() {
        let unpinned = items.filter { !$0.isPinned }
        guard unpinned.count > maxHistorySize else { return }
        let excess = unpinned.suffix(unpinned.count - maxHistorySize)
        for item in excess {
            if let name = item.imageFileName {
                persistence.deleteImageFile(fileName: name)
            }
            items.removeAll { $0.id == item.id }
        }
    }

    private func loadHistory() {
        items = persistence.loadItems()
    }
}
