import Foundation
import SwiftData
import SwiftUI

@Model
final class Category {
    var id: UUID
    var name: String
    var colorHex: String
    var icon: String
    var createdAt: Date

    @Relationship(deleteRule: .nullify, inverse: \Note.category)
    var notes: [Note]?

    init(name: String, colorHex: String, icon: String = "tag.fill") {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.icon = icon
        self.createdAt = Date()
        self.notes = []
    }

    var color: Color {
        Color(hex: colorHex)
    }

    var noteCount: Int {
        notes?.count ?? 0
    }

    static let defaultCategories: [(String, String, String)] = [
        ("Kişisel", "#A8D8EA", "person.fill"),
        ("İş", "#7EC8C8", "briefcase.fill"),
        ("Fikir", "#FFD93D", "lightbulb.fill"),
        ("Önemli", "#FF6B6B", "star.fill")
    ]
}
