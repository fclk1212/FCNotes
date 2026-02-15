import Foundation
import SwiftData

@Model
final class Folder {
    var id: UUID
    var name: String
    var icon: String
    var createdAt: Date

    @Relationship(deleteRule: .nullify, inverse: \Note.folder)
    var notes: [Note]?

    init(name: String, icon: String = "folder.fill") {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.createdAt = Date()
        self.notes = []
    }

    var noteCount: Int {
        notes?.count ?? 0
    }
}
