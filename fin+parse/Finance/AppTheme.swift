// AppTheme.swift — Design tokens for FinaApp

import SwiftUI

struct AppTheme {
    // MARK: - Brand & Status Colors
    // Slightly more saturated to stand out against white backgrounds
    static let accent      = Color(hex: "#5D5CDE")
    static let accentSoft  = Color(hex: "#5D5CDE").opacity(0.08)
    static let green       = Color(hex: "#10B981")
    static let greenSoft   = Color(hex: "#10B981").opacity(0.12)
    static let red         = Color(hex: "#EF4444")
    static let redSoft     = Color(hex: "#EF4444").opacity(0.1)
    static let yellow      = Color(hex: "#F59E0B")
    static let yellowSoft  = Color(hex: "#F59E0B").opacity(0.1)
    static let teal        = Color(hex: "#06B6D4")
    static let orange      = Color(hex: "#F97316")
    static let purple      = Color(hex: "#7C3AED")
    static let teals        = Color(hex: "#06B6D4")

    // MARK: - Shadows
    static let shadowXS    = Color.black.opacity(0.03)
    static let shadowSM    = Color.black.opacity(0.07)
    static let shadowMD    = Color.black.opacity(0.12)

    // MARK: - Structural Colors (The "Bright" UI)
    static let bg          = Color(hex: "#F9FAFB") // Very light grey (Slate 50)
    static let surface     = Color.white           // Pure white for cards
    static let surface2    = Color(hex: "#F3F4F6") // Light grey for inner fields (Grey 100)
    static let border      = Color.black.opacity(0.06) // Very thin, subtle border
    
    // MARK: - Typography
    static let textPrimary = Color(hex: "#111827") // Near-black (Slate 900)
    static let textMuted   = Color(hex: "#6B7280") // Mid-grey (Grey 500)

    // MARK: - Gradients
    static let accentGradient = LinearGradient(
        colors: [Color(hex: "#6366F1"), Color(hex: "#8B5CF6")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let greenGradient = LinearGradient(
        colors: [Color(hex: "#10B981"), Color(hex: "#34D399")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let cardGradient = LinearGradient(
        colors: [Color.white, Color(hex: "#F9FAFB")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    // MARK: - Design Constants (Unchanged)
    static let radiusSM: CGFloat = 10
    static let radiusMD: CGFloat = 16
    static let radiusLG: CGFloat = 22
    static let radiusXL: CGFloat = 28
}

// MARK: - Color hex init
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8)*17, (int >> 4 & 0xF)*17, (int & 0xF)*17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB,
            red: Double(r)/255, green: Double(g)/255,
            blue: Double(b)/255, opacity: Double(a)/255)
    }
}

// MARK: - View Modifiers
struct GlassCard: ViewModifier {
    var padding: CGFloat = 20
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusLG, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusLG, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
    }
}

struct PressEffect: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

extension View {
    func glassCard(padding: CGFloat = 20) -> some View {
        modifier(GlassCard(padding: padding))
    }
}


