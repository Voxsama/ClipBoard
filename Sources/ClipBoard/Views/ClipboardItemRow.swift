import SwiftUI

/// A single row in the clipboard history list.
struct ClipboardItemRow: View {
    let item: ClipboardItem
    let isHovered: Bool
    let onCopy: () -> Void
    let onPin: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            typeIcon

            VStack(alignment: .leading, spacing: 2) {
                contentPreview
                metadataLine
            }

            Spacer()

            if isHovered { actionButtons }

            if item.isPinned {
                Image(systemName: "pin.fill")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            isHovered
                ? Color(nsColor: .selectedContentBackgroundColor).opacity(0.3)
                : Color.clear
        )
        .cornerRadius(8)
        .contentShape(Rectangle())
        .onTapGesture { onCopy() }
        .contextMenu {
            Button("Copy") { onCopy() }
            Button(item.isPinned ? "Unpin" : "Pin") { onPin() }
            Divider()
            Button("Delete", role: .destructive) { onDelete() }
        }
    }

    // MARK: - Icon

    private var typeIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(iconBackground)
                .frame(width: 32, height: 32)
            Image(systemName: item.type.icon)
                .font(.system(size: 14))
                .foregroundColor(iconForeground)
        }
    }

    private var iconBackground: Color {
        switch item.type {
        case .text:  return .blue.opacity(0.15)
        case .image: return .purple.opacity(0.15)
        case .file:  return .orange.opacity(0.15)
        case .url:   return .green.opacity(0.15)
        }
    }

    private var iconForeground: Color {
        switch item.type {
        case .text:  return .blue
        case .image: return .purple
        case .file:  return .orange
        case .url:   return .green
        }
    }

    // MARK: - Preview

    @ViewBuilder
    private var contentPreview: some View {
        switch item.type {
        case .image:
            if let name = item.imageFileName,
               let data = PersistenceManager.shared.loadImageData(fileName: name),
               let nsImage = NSImage(data: data) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 60)
                    .cornerRadius(4)
            } else {
                Text("Image")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        default:
            Text(item.previewText)
                .font(.system(size: 12,
                              design: item.type == .url ? .monospaced : .default))
                .lineLimit(3)
                .foregroundColor(.primary)
        }
    }

    // MARK: - Metadata

    private var metadataLine: some View {
        HStack(spacing: 6) {
            if let app = item.sourceAppName {
                Text(app)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Text(item.createdAt.relativeDescription)
                .font(.caption2)
                .foregroundColor(.gray)
            if let c = item.characterCount {
                Text("• \(c) chars")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
    }

    // MARK: - Actions

    private var actionButtons: some View {
        HStack(spacing: 4) {
            Button(action: onCopy) {
                Image(systemName: "doc.on.doc").font(.caption)
            }
            .buttonStyle(.plain).help("Copy")

            Button(action: onPin) {
                Image(systemName: item.isPinned ? "pin.slash" : "pin").font(.caption)
            }
            .buttonStyle(.plain).help(item.isPinned ? "Unpin" : "Pin")

            Button(action: onDelete) {
                Image(systemName: "trash").font(.caption).foregroundColor(.red)
            }
            .buttonStyle(.plain).help("Delete")
        }
    }
}

// MARK: - Date helper

extension Date {
    var relativeDescription: String {
        let fmt = RelativeDateTimeFormatter()
        fmt.unitsStyle = .abbreviated
        return fmt.localizedString(for: self, relativeTo: Date())
    }
}
