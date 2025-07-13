import SwiftUI

extension Font {
    // MARK: - Headings
    static let themeLargeTitle = Font.system(size: 34, weight: .bold)
    static let themeTitle1 = Font.system(size: 28, weight: .bold)
    static let themeTitle2 = Font.system(size: 22, weight: .semibold)
    static let themeTitle3 = Font.system(size: 20, weight: .semibold)
    
    // MARK: - Body
    static let themeBody = Font.system(size: 17, weight: .regular)
    static let themeBodyBold = Font.system(size: 17, weight: .semibold)
    static let themeCallout = Font.system(size: 16, weight: .regular)
    static let themeSubheadline = Font.system(size: 15, weight: .regular)
    static let themeFootnote = Font.system(size: 13, weight: .regular)
    static let themeCaption1 = Font.system(size: 12, weight: .regular)
    static let themeCaption2 = Font.system(size: 11, weight: .regular)
    
    // MARK: - Special Purpose
    static let themeQuestionLarge = Font.system(size: 48, weight: .bold)
    static let themeQuestionMedium = Font.system(size: 36, weight: .bold)
    static let themeAnswerButton = Font.system(size: 24, weight: .semibold)
}

// MARK: - Line Spacing
struct LineSpacing {
    static let tight: CGFloat = 1.0
    static let `default`: CGFloat = 1.2
    static let loose: CGFloat = 1.5
}

// MARK: - Kerning
struct Kerning {
    static let tight: CGFloat = -0.5
    static let `default`: CGFloat = 0
    static let loose: CGFloat = 0.5
}