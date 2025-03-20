import SwiftUI
import SwiftData
import Charts

// とくい・にがての ひりつを ひょうじする まるグラフ
struct ProficiencyPieChart: View {
    let difficultQuestions: [DifficultQuestion]
    @State private var showingLegend = false
    @State private var animateChart = false
    
    var body: some View {
        let (proficientCount, difficultCount, undeterminedCount) = calculateProficiencyStats()
        
        ZStack(alignment: .topTrailing) {
            Chart {
                SectorMark(
                    angle: .value("もんだいすう", proficientCount),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5
                )
                .foregroundStyle(Color.green.gradient)
                .annotation(position: .overlay) {
                    if proficientCount > 0 {
                        Text("\(proficientCount)")
                            .font(.headline.bold())
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                    }
                }
                
                SectorMark(
                    angle: .value("もんだいすう", difficultCount),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5
                )
                .foregroundStyle(Color.red.gradient)
                .annotation(position: .overlay) {
                    if difficultCount > 0 {
                        Text("\(difficultCount)")
                            .font(.headline.bold())
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                    }
                }
                
                SectorMark(
                    angle: .value("もんだいすう", undeterminedCount),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5
                )
                .foregroundStyle(Color.gray.gradient)
                .annotation(position: .overlay) {
                    if undeterminedCount > 0 {
                        Text("\(undeterminedCount)")
                            .font(.headline.bold())
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                    }
                }
            }
            .scaleEffect(animateChart ? 1.0 : 0.8)
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    animateChart = true
                }
            }
            
            Button(action: {
                showingLegend.toggle()
            }) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .shadow(color: .white.opacity(0.5), radius: 2, x: 0, y: 0)
            }
            .padding(8)
            .popover(isPresented: $showingLegend, arrowEdge: .top) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("グラフの せつめい")
                        .font(.headline)
                        .foregroundColor(.indigo)
                        .padding(.bottom, 4)
                    
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 20, height: 20)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("とくい: \(proficientCount)もん")
                                .font(.subheadline)
                            Text("（せいかいりつ 70%いじょう）")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 20, height: 20)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("にがて: \(difficultCount)もん")
                                .font(.subheadline)
                            Text("（せいかいりつ 70%みまん）")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 20, height: 20)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        
                        Text("みかいとう: \(undeterminedCount)もん")
                            .font(.subheadline)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 3)
                )
                .padding(8)
                .presentationCompactAdaptation(.popover)
            }
        }
    }
    
    // とくい・にがて・みはんていの もんだいすうを けいさん
    private func calculateProficiencyStats() -> (proficient: Int, difficult: Int, undetermined: Int) {
        // 九九の もんだいは ぜんぶで 81もん
        let totalPossibleQuestions = 81
        
        // かいとうずみの もんだいの うち、にがてでないものは「とくい」とみなす
        let difficultCount = difficultQuestions.filter { $0.isDifficult }.count
        
        // かいとうずみだが にがてはんていに いたらない もんだい（かいとうすう 3みまん または せいかいりつ 70%いじょう）
        let notDifficultCount = difficultQuestions.filter { !$0.isDifficult }.count
        
        // まだ かいとうしていない もんだい
        let undeterminedCount = totalPossibleQuestions - difficultQuestions.count
        
        return (notDifficultCount, difficultCount, undeterminedCount)
    }
}

#Preview {
    ProficiencyPieChart(difficultQuestions: [])
        .frame(height: 300)
        .padding()
}