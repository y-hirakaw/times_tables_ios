import SwiftUI

extension Color {
    // MARK: - Primary Colors
    static let themePrimary = Color(hex: "007AFF")
    static let themePrimaryLight = Color(hex: "5AC8FA")
    static let themePrimaryDark = Color(hex: "005493")
    
    // MARK: - Secondary Colors
    static let themeSecondary = Color(hex: "34C759")
    static let themeSecondaryLight = Color(hex: "7DCE8A")
    static let themeError = Color(hex: "FF3B30")
    static let themeErrorLight = Color(hex: "FF6B64")
    
    // MARK: - Neutral Colors
    static let themeGray100 = Color(hex: "F2F2F7")
    static let themeGray200 = Color(hex: "E5E5EA")
    static let themeGray300 = Color(hex: "D1D1D6")
    static let themeGray400 = Color(hex: "C7C7CC")
    static let themeGray500 = Color(hex: "8E8E93")
    static let themeGray600 = Color(hex: "636366")
    static let themeGray700 = Color(hex: "48484A")
    static let themeGray800 = Color(hex: "3A3A3C")
    static let themeGray900 = Color(hex: "1C1C1E")
    
    // MARK: - Special Colors
    static let themeGold = Color(hex: "FFD700")
    static let themeSilver = Color(hex: "C0C0C0")
    static let themeBronze = Color(hex: "CD7F32")
    static let themeWarning = Color(hex: "FF9500")
    static let themeInfo = Color(hex: "5856D6")
    
    // MARK: - Semantic Colors (Dark Mode Compatible)
    static let themeBackground = Color("Background")
    static let themeCardBackground = Color("CardBackground")
    static let themePrimaryText = Color("PrimaryText")
    static let themeSecondaryText = Color("SecondaryText")
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}