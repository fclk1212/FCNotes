import SwiftUI

struct CategoryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCategory: Category?
    let categories: [Category]

    var body: some View {
        NavigationStack {
            List {
                Button {
                    selectedCategory = nil
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "tag.slash")
                            .foregroundStyle(.secondary)
                            .frame(width: 32)
                        Text("Kategori Yok")
                            .foregroundStyle(.fcDarkText)
                        Spacer()
                        if selectedCategory == nil {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.fcSeaGreen)
                        }
                    }
                }

                ForEach(categories) { category in
                    Button {
                        selectedCategory = category
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(category.color)
                                .frame(width: 12, height: 12)

                            Image(systemName: category.icon)
                                .foregroundStyle(category.color)
                                .frame(width: 32)

                            Text(category.name)
                                .foregroundStyle(.fcDarkText)

                            Spacer()

                            if selectedCategory?.id == category.id {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.fcSeaGreen)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Kategori Seç")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundStyle(.fcAccent)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
