import SwiftUI
import SwiftData

@Observable
final class FolderViewModel {
    var isShowingNewFolder = false
    var editingFolder: Folder?

    let folderIcons = [
        "folder.fill", "tray.fill", "archivebox.fill",
        "book.fill", "bookmark.fill", "heart.fill",
        "star.fill", "flag.fill", "tag.fill",
        "briefcase.fill", "house.fill", "graduationcap.fill"
    ]

    func createFolder(name: String, icon: String, context: ModelContext) {
        let folder = Folder(name: name, icon: icon)
        context.insert(folder)
        try? context.save()
    }

    func updateFolder(_ folder: Folder, name: String, icon: String, context: ModelContext) {
        folder.name = name
        folder.icon = icon
        try? context.save()
    }

    func deleteFolder(_ folder: Folder, context: ModelContext) {
        context.delete(folder)
        try? context.save()
    }

    func setupDefaultCategories(context: ModelContext) {
        let descriptor = FetchDescriptor<Category>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0

        guard existingCount == 0 else { return }

        for (name, color, icon) in Category.defaultCategories {
            let category = Category(name: name, colorHex: color, icon: icon)
            context.insert(category)
        }
        try? context.save()
    }
}
