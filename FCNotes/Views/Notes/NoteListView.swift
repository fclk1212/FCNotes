import SwiftUI
import SwiftData

struct NoteListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.updatedAt, order: .reverse) private var allNotes: [Note]
    @Query private var folders: [Folder]
    @Query private var categories: [Category]

    @Bindable var notesViewModel: NotesViewModel
    let folderViewModel: FolderViewModel

    @State private var showingNewNote = false
    @State private var editingNote: Note?
    @State private var isSelectionMode = false
    @State private var selectedNotes: Set<UUID> = []
    @State private var showingDeleteConfirmation = false
    @State private var showingSortOptions = false

    private var displayedNotes: [Note] {
        notesViewModel.filteredNotes(allNotes)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fcLightGray.ignoresSafeArea()

                if displayedNotes.isEmpty {
                    EmptyStateView(
                        icon: "note.text",
                        title: "Henüz not yok",
                        subtitle: "Yeni bir not oluşturmak için + butonuna dokunun"
                    )
                } else {
                    List {
                        ForEach(displayedNotes) { note in
                            Button {
                                if isSelectionMode {
                                    toggleSelection(note)
                                } else {
                                    editingNote = note
                                }
                            } label: {
                                NoteRowView(
                                    note: note,
                                    isSelected: selectedNotes.contains(note.id)
                                )
                            }
                            .listRowBackground(
                                selectedNotes.contains(note.id) ?
                                Color.fcLightBlue.opacity(0.1) : Color.white
                            )
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    notesViewModel.deleteNote(note, context: modelContext)
                                } label: {
                                    Label("Sil", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    notesViewModel.togglePin(note, context: modelContext)
                                } label: {
                                    Label(
                                        note.isPinned ? "Sabitlemeyi Kaldır" : "Sabitle",
                                        systemImage: note.isPinned ? "pin.slash" : "pin"
                                    )
                                }
                                .tint(.fcAccent)
                            }
                            .contextMenu {
                                noteContextMenu(for: note)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle(navigationTitle)
            .searchable(text: $notesViewModel.searchText, prompt: "Not ara...")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if isSelectionMode {
                        Button("İptal") {
                            isSelectionMode = false
                            selectedNotes.removeAll()
                        }
                        .foregroundStyle(.fcAccent)
                    }
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    if isSelectionMode {
                        Button {
                            // Select all
                            if selectedNotes.count == displayedNotes.count {
                                selectedNotes.removeAll()
                            } else {
                                selectedNotes = Set(displayedNotes.map(\.id))
                            }
                        } label: {
                            Image(systemName: selectedNotes.count == displayedNotes.count ?
                                  "checkmark.circle.fill" : "checkmark.circle")
                        }
                        .foregroundStyle(.fcAccent)

                        Button {
                            // Copy selected
                            let texts = displayedNotes
                                .filter { selectedNotes.contains($0.id) }
                                .map { "\($0.displayTitle)\n\($0.content)" }
                                .joined(separator: "\n\n---\n\n")
                            UIPasteboard.general.string = texts
                        } label: {
                            Image(systemName: "doc.on.doc")
                        }
                        .foregroundStyle(.fcAccent)
                        .disabled(selectedNotes.isEmpty)

                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            Image(systemName: "trash")
                        }
                        .foregroundStyle(.red)
                        .disabled(selectedNotes.isEmpty)
                    } else {
                        Menu {
                            Button {
                                isSelectionMode = true
                            } label: {
                                Label("Seç", systemImage: "checkmark.circle")
                            }

                            Menu("Sırala") {
                                ForEach(NotesViewModel.SortOrder.allCases, id: \.self) { order in
                                    Button {
                                        notesViewModel.sortOrder = order
                                    } label: {
                                        HStack {
                                            Text(order.rawValue)
                                            if notesViewModel.sortOrder == order {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundStyle(.fcAccent)
                        }

                        Button {
                            showingNewNote = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.fcSeaGreen)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingNewNote) {
                NoteEditorView(note: nil, notesViewModel: notesViewModel)
            }
            .sheet(item: $editingNote) { note in
                NoteEditorView(note: note, notesViewModel: notesViewModel)
            }
            .alert("Notları Sil", isPresented: $showingDeleteConfirmation) {
                Button("Sil", role: .destructive) {
                    let toDelete = allNotes.filter { selectedNotes.contains($0.id) }
                    notesViewModel.deleteNotes(toDelete, context: modelContext)
                    selectedNotes.removeAll()
                    isSelectionMode = false
                }
                Button("İptal", role: .cancel) {}
            } message: {
                Text("\(selectedNotes.count) not silinecek. Bu işlem geri alınamaz.")
            }
        }
    }

    private var navigationTitle: String {
        if isSelectionMode {
            return "\(selectedNotes.count) seçili"
        }
        if let folder = notesViewModel.selectedFolder {
            return folder.name
        }
        if let category = notesViewModel.selectedCategory {
            return category.name
        }
        return "Tüm Notlar"
    }

    private func toggleSelection(_ note: Note) {
        if selectedNotes.contains(note.id) {
            selectedNotes.remove(note.id)
        } else {
            selectedNotes.insert(note.id)
        }
    }

    @ViewBuilder
    private func noteContextMenu(for note: Note) -> some View {
        Button {
            notesViewModel.copyNoteContent(note)
        } label: {
            Label("Kopyala", systemImage: "doc.on.doc")
        }

        Button {
            notesViewModel.togglePin(note, context: modelContext)
        } label: {
            Label(
                note.isPinned ? "Sabitlemeyi Kaldır" : "Sabitle",
                systemImage: note.isPinned ? "pin.slash" : "pin"
            )
        }

        Menu("Klasöre Taşı") {
            Button {
                notesViewModel.moveToFolder(note, folder: nil, context: modelContext)
            } label: {
                Label("Klasör Yok", systemImage: "tray")
            }

            ForEach(folders) { folder in
                Button {
                    notesViewModel.moveToFolder(note, folder: folder, context: modelContext)
                } label: {
                    Label(folder.name, systemImage: folder.icon)
                }
            }
        }

        Menu("Kategori") {
            Button {
                notesViewModel.setCategory(note, category: nil, context: modelContext)
            } label: {
                Label("Kategori Yok", systemImage: "tag.slash")
            }

            ForEach(categories) { category in
                Button {
                    notesViewModel.setCategory(note, category: category, context: modelContext)
                } label: {
                    Label(category.name, systemImage: category.icon)
                }
            }
        }

        Divider()

        Button(role: .destructive) {
            notesViewModel.deleteNote(note, context: modelContext)
        } label: {
            Label("Sil", systemImage: "trash")
        }
    }
}
