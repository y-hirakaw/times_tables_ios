import SwiftUI

struct GraphTypeSelector: View {
    @Binding var selectedChartType: Int
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.spacing16) {
                Button {
                    selectedChartType = 0
                } label: {
                    VStack {
                        Image(systemName: "chart.pie.fill")
                            .font(.system(size: 24))
                        Text(NSLocalizedString("とくい・にがて", comment: "Strengths & Weaknesses"))
                            .font(.themeSubheadline)
                    }
                    .frame(width: 110)
                    .padding(.vertical, Spacing.spacing12)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.large)
                            .fill(selectedChartType == 0 ? Color.themePrimary : Color.white)
                            .shadow(color: Color.black.opacity(ShadowStyle.small.opacity),
                                   radius: ShadowStyle.small.radius,
                                   x: ShadowStyle.small.x,
                                   y: ShadowStyle.small.y)
                    )
                    .foregroundColor(selectedChartType == 0 ? .white : .themePrimary)
                }
                
                Button {
                    selectedChartType = 1
                } label: {
                    VStack {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 24))
                        Text(NSLocalizedString("にがての すうじ", comment: "Difficult Numbers"))
                            .font(.themeSubheadline)
                    }
                    .frame(width: 110)
                    .padding(.vertical, Spacing.spacing12)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.large)
                            .fill(selectedChartType == 1 ? Color.themePrimary : Color.white)
                            .shadow(color: Color.black.opacity(ShadowStyle.small.opacity),
                                   radius: ShadowStyle.small.radius,
                                   x: ShadowStyle.small.x,
                                   y: ShadowStyle.small.y)
                    )
                    .foregroundColor(selectedChartType == 1 ? .white : .themePrimary)
                }
                
                Button {
                    selectedChartType = 2
                } label: {
                    VStack {
                        Image(systemName: "chart.xyaxis.line")
                            .font(.system(size: 24))
                        Text(NSLocalizedString("だんごと", comment: "By Table"))
                            .font(.themeSubheadline)
                    }
                    .frame(width: 110)
                    .padding(.vertical, Spacing.spacing12)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.large)
                            .fill(selectedChartType == 2 ? Color.themePrimary : Color.white)
                            .shadow(color: Color.black.opacity(ShadowStyle.small.opacity),
                                   radius: ShadowStyle.small.radius,
                                   x: ShadowStyle.small.x,
                                   y: ShadowStyle.small.y)
                    )
                    .foregroundColor(selectedChartType == 2 ? .white : .themePrimary)
                }
            }
            .padding(.horizontal, Spacing.spacing8)
        }
    }
}

#Preview {
    GraphTypeSelector(selectedChartType: .constant(0))
}