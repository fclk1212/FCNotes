import SwiftUI
import SwiftData

@Observable
final class NotesViewModel {
    var searchText = ""
    var selectedFolder: Folder?
    var selectedCategory: Category?
    var sortOrder: SortOrder = .dateDescending

    enum SortOrder: String, CaseIterable {
        case dateDescending = "En Yeni"
        case dateAscending = "En Eski"
        case titleAscending = "A-Z"
        case titleDescending = "Z-A"

        var icon: String {
            switch self {
            case .dateDescending: return "arrow.down.circle"
            case .dateAscending: return "arrow.up.circle"
            case .titleAscending: return "textformat.abc"
            case .titleDescending: return "textformat.abc"
            }
        }
    }

    func filteredNotes(_ notes: [Note]) -> [Note] {
        var result = notes

        // Filter by folder
        if let folder = selectedFolder {
            result = result.filter { $0.folder?.id == folder.id }
        }

        // Filter by category
        if let category = selectedCategory {
            result = result.filter { $0.category?.id == category.id }
        }

        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Sort
        switch sortOrder {
        case .dateDescending:
            result.sort { $0.updatedAt > $1.updatedAt }
        case .dateAscending:
            result.sort { $0.updatedAt < $1.updatedAt }
        case .titleAscending:
            result.sort { $0.displayTitle.localizedCompare($1.displayTitle) == .orderedAscending }
        case .titleDescending:
            result.sort { $0.displayTitle.localizedCompare($1.displayTitle) == .orderedDescending }
        }

        // Pinned notes first
        let pinned = result.filter { $0.isPinned }
        let unpinned = result.filter { !$0.isPinned }
        return pinned + unpinned
    }

    func createNote(
        title: String,
        content: String,
        folder: Folder?,
        category: Category?,
        context: ModelContext
    ) -> Note {
        let note = Note(title: title, content: content, folder: folder, category: category)
        context.insert(note)
        try? context.save()
        return note
    }

    func deleteNote(_ note: Note, context: ModelContext) {
        context.delete(note)
        try? context.save()
    }

    func deleteNotes(_ notes: [Note], context: ModelContext) {
        for note in notes {
            context.delete(note)
        }
        try? context.save()
    }

    func togglePin(_ note: Note, context: ModelContext) {
        note.isPinned.toggle()
        note.updatedAt = Date()
        try? context.save()
    }

    func moveToFolder(_ note: Note, folder: Folder?, context: ModelContext) {
        note.folder = folder
        note.updatedAt = Date()
        try? context.save()
    }

    func setCategory(_ note: Note, category: Category?, context: ModelContext) {
        note.category = category
        note.updatedAt = Date()
        try? context.save()
    }

    func copyNoteContent(_ note: Note) {
        let text = "\(note.displayTitle)\n\n\(note.content)"
        UIPasteboard.general.string = text
    }

    func selectAllText() -> String {
        return ""
    }
}
