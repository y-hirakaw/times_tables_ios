import SwiftUI
import SwiftData
import Charts

// 得意・苦手の比率を表示する円グラフ
struct ProficiencyPieChart: View {
    let difficultQuestions: [DifficultQuestion]
    @State private var showingLegend = false
    
    var body: some View {
        let (proficientCount, difficultCount, undeterminedCount) = calculateProficiencyStats()
        
        ZStack(alignment: .topTrailing) {
            Chart {
                SectorMark(
                    angle: .value("問題数", proficientCount),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5
                )
                .foregroundStyle(Color.green)
                .annotation(position: .overlay) {
                    if proficientCount > 0 {
                        Text("\(proficientCount)")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                }
                
                SectorMark(
                    angle: .value("問題数", difficultCount),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5
                )
                .foregroundStyle(Color.red)
                .annotation(position: .overlay) {
                    if difficultCount > 0 {
                        Text("\(difficultCount)")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                }
                
                SectorMark(
                    angle: .value("問題数", undeterminedCount),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5
                )
                .foregroundStyle(Color.gray)
                .annotation(position: .overlay) {
                    if undeterminedCount > 0 {
                        Text("\(undeterminedCount)")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                }
            }
            
            Button(action: {
                showingLegend.toggle()
            }) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .padding(8)
            .popover(isPresented: $showingLegend, arrowEdge: .top) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("グラフの説明")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    HStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 16, height: 16)
                        Text("得意: \(proficientCount)問")
                        Text("(正解率70%以上)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 16, height: 16)
                        Text("苦手: \(difficultCount)問")
                        Text("(正解率70%未満)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 16, height: 16)
                        Text("未回答: \(undeterminedCount)問")
                    }
                }
                .padding()
                .presentationCompactAdaptation(.popover)
            }
        }
    }
    
    // 得意・苦手・未判定の問題数を計算
    private func calculateProficiencyStats() -> (proficient: Int, difficult: Int, undetermined: Int) {
        // 九九の問題は全部で81問あるが、1×1から9×9の81問中、意味のある問題は1×1から9×9の計81問
        let totalPossibleQuestions = 81
        
        // 回答済みの問題の内、苦手でないものは「得意」とみなす
        let difficultCount = difficultQuestions.filter { $0.isDifficult }.count
        
        // 回答済みだが苦手判定に至らない問題（回答数3未満または正解率70%以上）
        let notDifficultCount = difficultQuestions.filter { !$0.isDifficult }.count
        
        // まだ回答していない問題
        let undeterminedCount = totalPossibleQuestions - difficultQuestions.count
        
        return (notDifficultCount, difficultCount, undeterminedCount)
    }
}

#Preview {
    ProficiencyPieChart(difficultQuestions: [])
        .frame(height: 300)
        .padding()
}