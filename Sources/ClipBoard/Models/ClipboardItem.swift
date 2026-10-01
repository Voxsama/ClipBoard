import Foundation

/// Represents the type of content stored in a clipboard item.
enum ClipboardItemType: String, Codable, CaseIterable {
    case text
    case image
    case file
    case url

    /// SF Symbol icon name for this type.
    var icon: String {
        switch self {
        case .text: return "doc.text"
        case .image: return "photo"
        case .file: return "doc"
        case .url: return "link"
        }
    }

    /// Human-readable label.
    var label: String {
        switch self {
        case .text: return "Text"
        case .image: return "Image"
        case .file: return "File"
        case .url: return "Link"
        }
    }
}

/// A single clipboard history entry.
struct ClipboardItem: Identifiable, Codable, Equatable {
    let id: UUID
    let type: ClipboardItemType
    let textContent: String?
    let imageFileName: String?
    let fileURLs: [String]?
    let sourceAppName: String?
    let sourceAppBundleID: String?
    let createdAt: Date
    var isPinned: Bool
    var characterCount: Int?
    var wordCount: Int?

    /// Short text to show in the UI.
    var displayText: String {
        switch type {
        case .text, .url:
            return textContent ?? ""
        case .image:
            return "Image"
        case .file:
            if let urls = fileURLs {
                return urls.map { URL(fileURLWithPath: $0).lastPathComponent }.joined(separator: ", ")
            }
            return "File"
        }
    }

    /// Truncated preview for list rows.
    var previewText: String {
        let text = displayText
        if text.count > 200 {
            return String(text.prefix(200)) + "…"
        }
        return text
    }

    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        lhs.id == rhs.id
    }
}
