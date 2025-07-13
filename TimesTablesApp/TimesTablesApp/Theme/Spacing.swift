import SwiftUI

// MARK: - Spacing System (8pt Grid)
struct Spacing {
    static let spacing2: CGFloat = 2
    static let spacing4: CGFloat = 4
    static let spacing8: CGFloat = 8
    static let spacing12: CGFloat = 12
    static let spacing16: CGFloat = 16
    static let spacing20: CGFloat = 20
    static let spacing24: CGFloat = 24
    static let spacing32: CGFloat = 32
    static let spacing40: CGFloat = 40
    static let spacing48: CGFloat = 48
}

// MARK: - Corner Radius
struct CornerRadius {
    static let small: CGFloat = 4
    static let medium: CGFloat = 8
    static let large: CGFloat = 12
    static let xLarge: CGFloat = 16
    static let circle: CGFloat = .infinity
}

// MARK: - Shadow Styles
struct ShadowStyle {
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    let opacity: Double
    
    static let none = ShadowStyle(radius: 0, x: 0, y: 0, opacity: 0)
    static let small = ShadowStyle(radius: 4, x: 0, y: 2, opacity: 0.1)
    static let medium = ShadowStyle(radius: 8, x: 0, y: 4, opacity: 0.15)
    static let large = ShadowStyle(radius: 16, x: 0, y: 8, opacity: 0.2)
    static let xLarge = ShadowStyle(radius: 24, x: 0, y: 12, opacity: 0.25)
}

// MARK: - Animation Settings
struct AnimationStyle {
    static let springDefault = Animation.spring(response: 0.5, dampingFraction: 0.8)
    static let springBouncy = Animation.spring(response: 0.6, dampingFraction: 0.6)
    static let springSmooth = Animation.spring(response: 0.4, dampingFraction: 0.9)
    static let easeInOut = Animation.easeInOut(duration: 0.3)
    static let easeOut = Animation.easeOut(duration: 0.25)
    static let delayedSpring = Animation.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)
}