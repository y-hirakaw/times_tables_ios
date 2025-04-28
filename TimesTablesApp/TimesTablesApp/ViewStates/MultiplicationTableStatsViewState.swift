import SwiftUI
import SwiftData

@MainActor
class MultiplicationTableStatsViewState: ObservableObject {
    @Published var answerRecords: [AnswerTimeRecord] = []
    @Published var difficultQuestions: [DifficultQuestion] = []
    
    // 表示する段の数
    let tableRange = 1...9
    
    // ModelContextをpublicにして外部から再設定可能にする
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadData()
    }
    
    func loadData() {
        // AnswerTimeRecordデータの読み込み
        let answerRecordDescriptor = FetchDescriptor<AnswerTimeRecord>()
        do {
            answerRecords = try modelContext.fetch(answerRecordDescriptor)
        } catch {
            print("AnswerTimeRecordの読み込みに失敗: \(error)")
        }
        
        // DifficultQuestionデータの読み込み
        let difficultQuestionDescriptor = FetchDescriptor<DifficultQuestion>()
        do {
            difficultQuestions = try modelContext.fetch(difficultQuestionDescriptor)
        } catch {
            print("DifficultQuestionの読み込みに失敗: \(error)")
        }
        
        // デバッグ情報出力
        printDebugInfo()
    }
    
    // 段ごとの統計情報を取得
    func getTableStats(table: Int) -> (totalCount: Int, correctCount: Int, incorrectCount: Int, correctPercentage: Double) {
        var totalCorrect = 0
        var totalIncorrect = 0
        
        // 回答記録（AnswerTimeRecord）から統計を計算
        for record in answerRecords {
            // 問題IDを分解して、firstNumberとsecondNumberを取得
            let parts = record.questionId.split(separator: "x")
            if parts.count == 2, 
               let firstNumber = Int(parts[0]), 
               let secondNumber = Int(parts[1]) {
                
                // この段に関連する問題をすべてカウント（重複カウント許可）
                // firstNumberまたはsecondNumberが現在の段と一致する場合はカウント
                if firstNumber == table || secondNumber == table {
                    if record.isCorrect {
                        totalCorrect += 1
                    } else {
                        totalIncorrect += 1
                    }
                }
            }
        }
        
        let totalCount = totalCorrect + totalIncorrect
        
        var correctPercentage: Double = 0
        if totalCount > 0 {
            correctPercentage = Double(totalCorrect) / Double(totalCount) * 100
        }
        
        return (
            totalCount: totalCount,
            correctCount: totalCorrect,
            incorrectCount: totalIncorrect,
            correctPercentage: correctPercentage
        )
    }
    
    // デバッグ情報の出力
    private func printDebugInfo() {
        // デバッグ情報：データの数を確認
        print("AnswerTimeRecords: \(answerRecords.count)")
        print("DifficultQuestions: \(difficultQuestions.count)")
        
        // DifficultQuestions情報
        for question in difficultQuestions {
            print("苦手問題: \(question.identifier), 正解数: \(question.correctCount), 不正解数: \(question.incorrectCount)")
        }
        
        // AnswerTimeRecords情報
        var correctCount = 0
        var incorrectCount = 0
        for record in answerRecords {
            if record.isCorrect {
                correctCount += 1
            } else {
                incorrectCount += 1
            }
        }
        print("全回答データ - 正解: \(correctCount), 不正解: \(incorrectCount), 合計: \(answerRecords.count)")
        
        // 問題が属する段の決定ルールを説明
        print("【問題と段の関連付けルール】")
        print("- 問題は関連するすべての段でカウントされます")
        print("- 例：2×5の問題は「2の段」と「5の段」の両方でカウントされます")
        print("- そのため、全段の合計は実際の問題数よりも多くなります")
        
        // 各段の問題数と合計をデバッグ表示
        var totalAllTables = 0
        for table in 1...9 {
            let stats = getTableStats(table: table)
            print("\(table)の段の問題数: \(stats.totalCount) (正解: \(stats.correctCount), 不正解: \(stats.incorrectCount))")
            totalAllTables += stats.totalCount
        }
        print("全段の問題数合計: \(totalAllTables) ※問題の重複カウントを含む")
        print("実際の問題数: \(answerRecords.count)")
    }
} 