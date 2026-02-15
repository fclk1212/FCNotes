import SwiftUI
import SwiftData

struct FolderListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Folder.createdAt) private var folders: [Folder]
    @Query(sort: \Category.createdAt) private var categories: [Category]
    @Query private var allNotes: [Note]

    let notesViewModel: NotesViewModel
    let folderViewModel: FolderViewModel

    @State private var showingNewFolder = false
    @State private var newFolderName = ""
    @State private var newFolderIcon = "folder.fill"
    @State private var editingFolder: Folder?

    var body: some View {
        List {
            // All Notes
            Section {
                Button {
                    notesViewModel.selectedFolder = nil
                    notesViewModel.selectedCategory = nil
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "tray.full.fill")
                            .foregroundStyle(.fcSeaGreen)
                            .font(.title3)
                            .frame(width: 32)

                        Text("Tüm Notlar")
                            .font(.body.weight(.medium))
                            .foregroundStyle(.fcDarkText)

                        Spacer()

                        Text("\(allNotes.count)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.fcMediumGray.opacity(0.5))
                            .clipShape(Capsule())
                    }
                    .padding(.vertical, 4)
                }
            }

            // Folders
            Section("Klasörler") {
                ForEach(folders) { folder in
                    Button {
                        notesViewModel.selectedFolder = folder
                        notesViewModel.selectedCategory = nil
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: folder.icon)
                                .foregroundStyle(.fcLightBlue)
                                .font(.title3)
                                .frame(width: 32)

                            Text(folder.name)
                                .font(.body.weight(.medium))
                                .foregroundStyle(.fcDarkText)

                            Spacer()

                            Text("\(folder.noteCount)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.fcMediumGray.opacity(0.5))
                                .clipShape(Capsule())
                        }
                        .padding(.vertical, 4)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            folderViewModel.deleteFolder(folder, context: modelContext)
                        } label: {
                            Label("Sil", systemImage: "trash")
                        }

                        Button {
                            editingFolder = folder
                            newFolderName = folder.name
                            newFolderIcon = folder.icon
                        } label: {
                            Label("Düzenle", systemImage: "pencil")
                        }
                        .tint(.fcAccent)
                    }
                }

                Button {
                    newFolderName = ""
                    newFolderIcon = "folder.fill"
                    showingNewFolder = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.fcSeaGreen)
                            .font(.title3)
                            .frame(width: 32)

                        Text("Yeni Klasör")
                            .font(.body)
                            .foregroundStyle(.fcSeaGreen)
                    }
                    .padding(.vertical, 4)
                }
            }

            // Categories
            Section("Kategoriler") {
                ForEach(categories) { category in
                    Button {
                        notesViewModel.selectedCategory = category
                        notesViewModel.selectedFolder = nil
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: category.icon)
                                .foregroundStyle(category.color)
                                .font(.title3)
                                .frame(width: 32)

                            Text(category.name)
                                .font(.body.weight(.medium))
                                .foregroundStyle(.fcDarkText)

                            Spacer()

                            Text("\(category.noteCount)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(category.color.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.fcLightGray)
        .alert("Yeni Klasör", isPresented: $showingNewFolder) {
            TextField("Klasör adı", text: $newFolderName)
            Button("Oluştur") {
                guard !newFolderName.isEmpty else { return }
                folderViewModel.createFolder(name: newFolderName, icon: newFolderIcon, context: modelContext)
            }
            Button("İptal", role: .cancel) {}
        }
        .alert("Klasörü Düzenle", isPresented: Binding(
            get: { editingFolder != nil },
            set: { if !$0 { editingFolder = nil } }
        )) {
            TextField("Klasör adı", text: $newFolderName)
            Button("Kaydet") {
                if let folder = editingFolder {
                    folderViewModel.updateFolder(folder, name: newFolderName, icon: newFolderIcon, context: modelContext)
                }
                editingFolder = nil
            }
            Button("İptal", role: .cancel) {
                editingFolder = nil
            }
        }
        .onAppear {
            folderViewModel.setupDefaultCategories(context: modelContext)
        }
    }
}
