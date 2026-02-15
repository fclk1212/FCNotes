import SwiftUI
import SwiftData

struct NoteEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var folders: [Folder]
    @Query private var categories: [Category]

    let note: Note?
    let notesViewModel: NotesViewModel

    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedFolder: Folder?
    @State private var selectedCategory: Category?
    @State private var showingCategoryPicker = false
    @State private var showingFolderPicker = false
    @State private var showCopiedToast = false

    private var isNewNote: Bool { note == nil }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Title field
                    TextField("Başlık", text: $title)
                        .font(.title2.bold())
                        .foregroundStyle(.fcDarkText)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    Divider()
                        .padding(.horizontal)

                    // Metadata bar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // Folder picker
                            Button {
                                showingFolderPicker = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: selectedFolder?.icon ?? "folder")
                                        .font(.caption)
                                    Text(selectedFolder?.name ?? "Klasör")
                                        .font(.caption)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.fcLightBlue.opacity(0.2))
                                .clipShape(Capsule())
                                .foregroundStyle(.fcAccent)
                            }

                            // Category picker
                            Button {
                                showingCategoryPicker = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: selectedCategory?.icon ?? "tag")
                                        .font(.caption)
                                    Text(selectedCategory?.name ?? "Kategori")
                                        .font(.caption)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background((selectedCategory?.color ?? .fcSeaGreen).opacity(0.2))
                                .clipShape(Capsule())
                                .foregroundStyle(selectedCategory?.color ?? .fcSeaGreen)
                            }

                            // Copy button
                            Button {
                                UIPasteboard.general.string = "\(title)\n\n\(content)"
                                showCopiedToast = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    showCopiedToast = false
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "doc.on.doc")
                                        .font(.caption)
                                    Text("Kopyala")
                                        .font(.caption)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.fcMediumGray.opacity(0.5))
                                .clipShape(Capsule())
                                .foregroundStyle(.fcDarkText)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Content editor
                    TextEditor(text: $content)
                        .font(.body)
                        .foregroundStyle(.fcDarkText)
                        .frame(minHeight: 400)
                        .padding(.horizontal, 12)
                        .scrollContentBackground(.hidden)
                        .overlay(alignment: .topLeading) {
                            if content.isEmpty {
                                Text("Notunuzu yazın...")
                                    .font(.body)
                                    .foregroundStyle(.secondary.opacity(0.5))
                                    .padding(.horizontal, 17)
                                    .padding(.top, 8)
                                    .allowsHitTesting(false)
                            }
                        }
                }
            }
            .background(Color.fcLightGray)
            .navigationTitle(isNewNote ? "Yeni Not" : "Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                    .foregroundStyle(.fcAccent)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        saveNote()
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundStyle(.fcSeaGreen)
                    .disabled(title.isEmpty && content.isEmpty)
                }
            }
            .sheet(isPresented: $showingFolderPicker) {
                folderPickerSheet
            }
            .sheet(isPresented: $showingCategoryPicker) {
                CategoryPickerView(selectedCategory: $selectedCategory, categories: categories)
            }
            .overlay {
                if showCopiedToast {
                    VStack {
                        Spacer()
                        Text("Kopyalandı!")
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.fcSeaGreen)
                            .clipShape(Capsule())
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .padding(.bottom, 40)
                    }
                    .animation(.spring(), value: showCopiedToast)
                }
            }
        }
        .onAppear {
            if let note {
                title = note.title
                content = note.content
                selectedFolder = note.folder
                selectedCategory = note.category
            }
        }
    }

    private var folderPickerSheet: some View {
        NavigationStack {
            List {
                Button {
                    selectedFolder = nil
                    showingFolderPicker = false
                } label: {
                    HStack {
                        Image(systemName: "tray")
                        Text("Klasör Yok")
                        Spacer()
                        if selectedFolder == nil {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.fcSeaGreen)
                        }
                    }
                }
                .foregroundStyle(.fcDarkText)

                ForEach(folders) { folder in
                    Button {
                        selectedFolder = folder
                        showingFolderPicker = false
                    } label: {
                        HStack {
                            Image(systemName: folder.icon)
                                .foregroundStyle(.fcAccent)
                            Text(folder.name)
                            Spacer()
                            if selectedFolder?.id == folder.id {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.fcSeaGreen)
                            }
                        }
                    }
                    .foregroundStyle(.fcDarkText)
                }
            }
            .navigationTitle("Klasör Seç")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        showingFolderPicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func saveNote() {
        if let note {
            note.title = title
            note.content = content
            note.folder = selectedFolder
            note.category = selectedCategory
            note.updatedAt = Date()
            try? modelContext.save()
        } else {
            let _ = notesViewModel.createNote(
                title: title,
                content: content,
                folder: selectedFolder,
                category: selectedCategory,
                context: modelContext
            )
        }
    }
}
