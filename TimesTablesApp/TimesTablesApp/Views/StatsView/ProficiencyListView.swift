import SwiftUI
import SwiftData

// しゅうじゅくどの いちらんを ひょうじする ビュー
struct ProficiencyListView: View {
    let difficultQuestions: [DifficultQuestion]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // にがて もんだいの いちらん
            if !difficultQuestions.filter({ $0.isDifficult }).isEmpty {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("にがてな もんだい:")
                        .font(.headline)
                        .foregroundColor(.indigo)
                }
                
                let difficultOnes = difficultQuestions.filter { $0.isDifficult }
                    .sorted { $0.incorrectPercentage > $1.incorrectPercentage }
                    .prefix(5)
                
                ForEach(Array(difficultOnes), id: \.id) { question in
                    HStack {
                        Text("\(question.firstNumber) × \(question.secondNumber)")
                            .font(.title3)
                            .bold()
                        
                        Spacer()
                        
                        Text("まちがえる りつ: \(Int(question.incorrectPercentage))%")
                            .font(.callout)
                            .foregroundColor(.red)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.red.opacity(0.15))
                            )
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.7))
                            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                    )
                }
                
                if difficultOnes.count > 5 {
                    Text("ほか \(difficultQuestions.filter { $0.isDifficult }.count - 5) もん")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
            
            Divider()
                .padding(.vertical, 8)
            
            // もっとも とくいな もんだいの いちらん
            let proficientOnes = difficultQuestions
                .filter { $0.totalAttempts >= 3 && !$0.isDifficult }
                .sorted { $0.incorrectPercentage < $1.incorrectPercentage }
                .prefix(5)
            
            if !proficientOnes.isEmpty {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("とくいな もんだい:")
                        .font(.headline)
                        .foregroundColor(.indigo)
                }
                
                ForEach(Array(proficientOnes), id: \.id) { question in
                    HStack {
                        Text("\(question.firstNumber) × \(question.secondNumber)")
                            .font(.title3)
                            .bold()
                        
                        Spacer()
                        
                        Text("せいかいりつ: \(Int(100 - question.incorrectPercentage))%")
                            .font(.callout)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.green.opacity(0.15))
                            )
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.7))
                            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                    )
                }
            }
        }
    }
}

#Preview {
    ProficiencyListView(difficultQuestions: [])
        .padding()
}