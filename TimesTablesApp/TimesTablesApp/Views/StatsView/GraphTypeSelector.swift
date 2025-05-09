import SwiftUI

struct GraphTypeSelector: View {
    @Binding var selectedChartType: Int
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                Button {
                    selectedChartType = 0
                } label: {
                    VStack {
                        Image(systemName: "chart.pie.fill")
                            .font(.system(size: 24))
                        Text("とくい・にがて")
                            .font(.subheadline)
                    }
                    .frame(width: 110)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(selectedChartType == 0 ? Color.blue.opacity(0.8) : Color.white.opacity(0.8))
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    .foregroundColor(selectedChartType == 0 ? .white : .blue)
                }
                
                Button {
                    selectedChartType = 1
                } label: {
                    VStack {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 24))
                        Text("にがての すうじ")
                            .font(.subheadline)
                    }
                    .frame(width: 110)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(selectedChartType == 1 ? Color.blue.opacity(0.8) : Color.white.opacity(0.8))
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    .foregroundColor(selectedChartType == 1 ? .white : .blue)
                }
                
                Button {
                    selectedChartType = 2
                } label: {
                    VStack {
                        Image(systemName: "chart.xyaxis.line")
                            .font(.system(size: 24))
                        Text("だんごと")
                            .font(.subheadline)
                    }
                    .frame(width: 110)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(selectedChartType == 2 ? Color.blue.opacity(0.8) : Color.white.opacity(0.8))
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    .foregroundColor(selectedChartType == 2 ? .white : .blue)
                }
            }
            .padding(.horizontal, 5)
        }
    }
}

#Preview {
    GraphTypeSelector(selectedChartType: .constant(0))
}