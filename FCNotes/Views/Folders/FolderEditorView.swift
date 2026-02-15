import SwiftUI

struct FolderEditorView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var folderName: String
    @Binding var folderIcon: String
    let icons: [String]
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Klasör Adı") {
                    TextField("Klasör adı girin", text: $folderName)
                }

                Section("İkon Seç") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(icons, id: \.self) { icon in
                            Button {
                                folderIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .frame(width: 50, height: 50)
                                    .background(
                                        folderIcon == icon ?
                                        Color.fcLightBlue.opacity(0.3) : Color.fcMediumGray.opacity(0.3)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundStyle(folderIcon == icon ? .fcSeaGreen : .fcDarkText)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Klasör")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        onSave()
                        dismiss()
                    }
                    .disabled(folderName.isEmpty)
                    .foregroundStyle(.fcSeaGreen)
                }
            }
        }
    }
}
