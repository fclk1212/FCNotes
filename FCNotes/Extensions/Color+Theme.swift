import SwiftUI

extension Color {
    // MARK: - Theme Colors
    static let fcLightBlue = Color(hex: "#A8D8EA")
    static let fcSeaGreen = Color(hex: "#7EC8C8")
    static let fcDarkText = Color(hex: "#2D3436")
    static let fcLightGray = Color(hex: "#F8F9FA")
    static let fcMediumGray = Color(hex: "#DFE6E9")
    static let fcAccent = Color(hex: "#6CB4D9")
    static let fcGradientStart = Color(hex: "#A8D8EA")
    static let fcGradientEnd = Color(hex: "#7EC8C8")

    // MARK: - Hex Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
// MARK: - ShapeStyle Support
extension ShapeStyle where Self == Color {
    static var fcLightBlue: Color { Color.fcLightBlue }
    static var fcSeaGreen: Color { Color.fcSeaGreen }
    static var fcDarkText: Color { Color.fcDarkText }
    static var fcLightGray: Color { Color.fcLightGray }
    static var fcMediumGray: Color { Color.fcMediumGray }
    static var fcAccent: Color { Color.fcAccent }
}
// MARK: - Theme Gradient
struct FCGradient {
    static let main = LinearGradient(
        colors: [.fcLightBlue, .fcSeaGreen],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let subtle = LinearGradient(
        colors: [.fcLightBlue.opacity(0.3), .fcSeaGreen.opacity(0.3)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
