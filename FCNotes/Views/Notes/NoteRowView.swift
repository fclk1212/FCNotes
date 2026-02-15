import SwiftUI

struct NoteRowView: View {
    let note: Note
    var isSelected: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            // Selection indicator
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.fcSeaGreen)
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    if note.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption)
                            .foregroundStyle(.fcAccent)
                    }

                    Text(note.displayTitle)
                        .font(.headline)
                        .foregroundStyle(.fcDarkText)
                        .lineLimit(1)
                }

                if !note.preview.isEmpty {
                    Text(note.preview)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                HStack(spacing: 8) {
                    Text(note.formattedDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let category = note.category {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(category.color)
                                .frame(width: 8, height: 8)

                            Text(category.name)
                                .font(.caption)
                                .foregroundStyle(category.color)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(category.color.opacity(0.1))
                        .clipShape(Capsule())
                    }

                    if let folder = note.folder {
                        HStack(spacing: 4) {
                            Image(systemName: folder.icon)
                                .font(.caption2)
                            Text(folder.name)
                                .font(.caption)
                        }
                        .foregroundStyle(.fcAccent)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .contentShape(Rectangle())
    }
}
