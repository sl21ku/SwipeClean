// ThemeColors.swift
// Color tokens and extensions for SwipeClean SwiftUI styling.

import SwiftUI

struct ThemeColors: Sendable {
    let name: String
    let bg: Color
    let cardBg: Color
    let textMain: Color
    let textMuted: Color
    let accentKeep: Color
    let accentKeepBg: Color
    let accentDelete: Color
    let accentDeleteBg: Color
    let accentGold: Color
    let accentGoldBg: Color
    let boardBg: Color
    
    static let classic = ThemeColors(
        name: "classic",
        bg: Color(hex: "#f7f3eb"),
        cardBg: Color.white,
        textMain: Color(hex: "#4e4039"),
        textMuted: Color(hex: "#8d7b70"),
        accentKeep: Color(hex: "#9ab395"),
        accentKeepBg: Color(hex: "#e6eede"),
        accentDelete: Color(hex: "#d48b75"),
        accentDeleteBg: Color(hex: "#f9ebe5"),
        accentGold: Color(hex: "#dfb26c"),
        accentGoldBg: Color(hex: "#f9f2e3"),
        boardBg: Color(hex: "#ecdccb")
    )
    
    static let cyber = ThemeColors(
        name: "cyber",
        bg: Color(hex: "#0f0913"),
        cardBg: Color(hex: "#1c102b"),
        textMain: Color(hex: "#00ffcc"),
        textMuted: Color(hex: "#bc93f9"),
        accentKeep: Color(hex: "#00ffcc"),
        accentKeepBg: Color(hex: "#1b4b45"),
        accentDelete: Color(hex: "#ff007f"),
        accentDeleteBg: Color(hex: "#520f32"),
        accentGold: Color(hex: "#ffcc00"),
        accentGoldBg: Color(hex: "#3d340b"),
        boardBg: Color(hex: "#271442")
    )
    
    static let forest = ThemeColors(
        name: "forest",
        bg: Color(hex: "#1c261e"),
        cardBg: Color(hex: "#2b3a30"),
        textMain: Color(hex: "#ecf3ed"),
        textMuted: Color(hex: "#839d89"),
        accentKeep: Color(hex: "#88c070"),
        accentKeepBg: Color(hex: "#23421d"),
        accentDelete: Color(hex: "#cf7c7c"),
        accentDeleteBg: Color(hex: "#4f2323"),
        accentGold: Color(hex: "#e2c074"),
        accentGoldBg: Color(hex: "#38301d"),
        boardBg: Color(hex: "#222e25")
    )
    
    static let pastel = ThemeColors(
        name: "pastel",
        bg: Color(hex: "#faf0f2"),
        cardBg: Color.white,
        textMain: Color(hex: "#6b4d53"),
        textMuted: Color(hex: "#bda2a7"),
        accentKeep: Color(hex: "#b5e2b9"),
        accentKeepBg: Color(hex: "#eaf8eb"),
        accentDelete: Color(hex: "#ffb7b2"),
        accentDeleteBg: Color(hex: "#ffebeb"),
        accentGold: Color(hex: "#ffdac1"),
        accentGoldBg: Color(hex: "#fff6eb"),
        boardBg: Color(hex: "#f5dfdf")
    )
    
    static func getTheme(_ name: String) -> ThemeColors {
        switch name {
        case "cyber": return .cyber
        case "forest": return .forest
        case "pastel": return .pastel
        default: return .classic
        }
    }
}

// SwiftUI hex Color initializer
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
