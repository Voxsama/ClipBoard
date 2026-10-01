import SwiftUI

/// The main floating-panel view – search bar, filter chips, scrollable item list.
struct ClipboardPopoverView: View {
    @ObservedObject var viewModel: ClipboardViewModel
    @State private var hoveredItemId: UUID?

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            filterBar
            Divider()

            if viewModel.filteredItems.isEmpty {
                emptyState
            } else {
                itemsList
            }

            Divider()
            footerView
        }
        .frame(width: 380, height: 520)
        .background(VisualEffectBackground(material: .popover, blendingMode: .behindWindow))
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "doc.on.clipboard")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                Text("ClipBoard")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.items.count) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            // Search field
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search clipboard history…", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                if !viewModel.searchText.isEmpty {
                    Button { viewModel.searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
    }

    // MARK: - Filter Chips

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                FilterChip(title: "All", isSelected: viewModel.selectedFilter == nil) {
                    viewModel.selectedFilter = nil
                }
                ForEach(ClipboardItemType.allCases, id: \.self) { type in
                    FilterChip(
                        title: type.label,
                        icon: type.icon,
                        isSelected: viewModel.selectedFilter == type
                    ) {
                        viewModel.selectedFilter =
                            viewModel.selectedFilter == type ? nil : type
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
    }

    // MARK: - List

    private var itemsList: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                ForEach(viewModel.filteredItems) { item in
                    ClipboardItemRow(
                        item: item,
                        isHovered: hoveredItemId == item.id,
                        onCopy: { viewModel.copyToClipboard(item) },
                        onPin: { viewModel.togglePin(item) },
                        onDelete: { viewModel.deleteItem(item) }
                    )
                    .onHover { over in hoveredItemId = over ? item.id : nil }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "clipboard")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text(viewModel.searchText.isEmpty
                 ? "No clipboard history yet"
                 : "No results found")
                .font(.headline)
                .foregroundColor(.secondary)
            Text(viewModel.searchText.isEmpty
                 ? "Copy something to get started"
                 : "Try a different search term")
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
        }
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack {
            if viewModel.pinnedCount > 0 {
                Image(systemName: "pin.fill")
                    .font(.caption2)
                    .foregroundColor(.orange)
                Text("\(viewModel.pinnedCount) pinned")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button("Clear All") { viewModel.clearAll() }
                .font(.caption)
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon { Image(systemName: icon).font(.caption2) }
                Text(title).font(.caption)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(isSelected ? Color.accentColor : Color(nsColor: .controlBackgroundColor))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - NSVisualEffectView wrapper

struct VisualEffectBackground: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let v = NSVisualEffectView()
        v.material = material
        v.blendingMode = blendingMode
        v.state = .active
        return v
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
