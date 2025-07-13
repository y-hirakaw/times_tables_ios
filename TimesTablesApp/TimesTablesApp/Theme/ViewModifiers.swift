import SwiftUI

// MARK: - Primary Button
struct PrimaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.themeBodyBold)
            .foregroundColor(.white)
            .padding(.horizontal, Spacing.spacing24)
            .padding(.vertical, Spacing.spacing12)
            .background(Color.themePrimary)
            .cornerRadius(CornerRadius.medium)
            .shadow(color: Color.black.opacity(ShadowStyle.medium.opacity),
                   radius: ShadowStyle.medium.radius,
                   x: ShadowStyle.medium.x,
                   y: ShadowStyle.medium.y)
    }
}

// MARK: - Secondary Button
struct SecondaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.themeBodyBold)
            .foregroundColor(.themePrimary)
            .padding(.horizontal, Spacing.spacing24)
            .padding(.vertical, Spacing.spacing12)
            .background(Color.themeGray200)
            .cornerRadius(CornerRadius.medium)
    }
}

// MARK: - Answer Button
struct AnswerButtonStyle: ViewModifier {
    let isSelected: Bool
    let isCorrect: Bool?
    
    func body(content: Content) -> some View {
        content
            .font(.themeAnswerButton)
            .foregroundColor(foregroundColor)
            .frame(width: 80, height: 80)
            .background(backgroundColor)
            .cornerRadius(CornerRadius.large)
            .shadow(color: Color.black.opacity(ShadowStyle.medium.opacity),
                   radius: ShadowStyle.medium.radius,
                   x: ShadowStyle.medium.x,
                   y: ShadowStyle.medium.y)
            .scaleEffect(isSelected ? 0.95 : 1.0)
            .animation(AnimationStyle.springBouncy, value: isSelected)
    }
    
    var foregroundColor: Color {
        if let isCorrect = isCorrect {
            return .white
        }
        return isSelected ? .white : .themeGray700
    }
    
    var backgroundColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? .themeSecondary : .themeError
        }
        return isSelected ? .themePrimary : .themeGray200
    }
}

// MARK: - Card Style
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Spacing.spacing16)
            .background(Color.white)
            .cornerRadius(CornerRadius.large)
            .shadow(color: Color.black.opacity(ShadowStyle.medium.opacity),
                   radius: ShadowStyle.medium.radius,
                   x: ShadowStyle.medium.x,
                   y: ShadowStyle.medium.y)
    }
}

// MARK: - Input Field
struct InputFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.themeBody)
            .padding(.horizontal, Spacing.spacing16)
            .padding(.vertical, Spacing.spacing12)
            .background(Color.themeGray100)
            .cornerRadius(CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(Color.themeGray300, lineWidth: 1)
            )
    }
}

// MARK: - Badge Style
struct BadgeStyle: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .font(.themeCaption1)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, Spacing.spacing8)
            .padding(.vertical, Spacing.spacing4)
            .background(color)
            .cornerRadius(CornerRadius.small)
    }
}

// MARK: - Convenience Extensions
extension View {
    func primaryButtonStyle() -> some View {
        modifier(PrimaryButtonStyle())
    }
    
    func secondaryButtonStyle() -> some View {
        modifier(SecondaryButtonStyle())
    }
    
    func answerButtonStyle(isSelected: Bool, isCorrect: Bool? = nil) -> some View {
        modifier(AnswerButtonStyle(isSelected: isSelected, isCorrect: isCorrect))
    }
    
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
    
    func inputFieldStyle() -> some View {
        modifier(InputFieldStyle())
    }
    
    func badgeStyle(color: Color) -> some View {
        modifier(BadgeStyle(color: color))
    }
}

// MARK: - Progress Bar Component
struct ProgressBar: View {
    let progress: Double
    let height: CGFloat = 8
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.themeGray200)
                    .frame(height: height)
                
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.themePrimary)
                    .frame(width: geometry.size.width * progress, height: height)
                    .animation(AnimationStyle.springSmooth, value: progress)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Question Card Component
struct QuestionCard: View {
    let question: String
    let timeRemaining: Int
    
    var body: some View {
        VStack(spacing: Spacing.spacing24) {
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(timeColor)
                Text("\(timeRemaining)秒")
                    .font(.themeSubheadline)
                    .foregroundColor(timeColor)
            }
            
            Text(question)
                .font(.themeQuestionLarge)
                .foregroundColor(.themeGray800)
                .multilineTextAlignment(.center)
        }
        .padding(Spacing.spacing32)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
    
    var timeColor: Color {
        switch timeRemaining {
        case 0...3:
            return .themeError
        case 4...6:
            return .themeWarning
        default:
            return .themeSecondaryText
        }
    }
}

// MARK: - Success Animation Component
struct SuccessAnimation: View {
    @State private var scale = 0.5
    @State private var opacity = 0.0
    
    var body: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 80))
            .foregroundColor(.themeSecondary)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(AnimationStyle.springBouncy) {
                    scale = 1.0
                    opacity = 1.0
                }
                
                withAnimation(AnimationStyle.easeOut.delay(0.8)) {
                    opacity = 0.0
                }
            }
    }
}