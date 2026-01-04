import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

struct AppColors {
    static let primaryPurple = Color(hex: 0x7B4DFF)
    static let secondaryPurple = Color(hex: 0x9C6EFF)
    static let lightPurple = Color(hex: 0xE0D0FF)
    static let darkPurple = Color(hex: 0x3A2080)
}
