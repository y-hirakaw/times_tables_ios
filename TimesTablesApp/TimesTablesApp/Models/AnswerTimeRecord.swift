import Foundation
import SwiftData

/// 問題の回答時間を記録するモデル
@Model
final class AnswerTimeRecord {
    /// 回答日時
    var date: Date
    /// 問題の一意識別子（例：「3x4」）
    var questionId: String
    /// 回答時間（秒単位）
    var answerTimeSeconds: Double
    /// 正解したかどうか
    var isCorrect: Bool
    /// 時間切れだったかどうか
    var isTimeout: Bool
    
    /// 初期化メソッド
    /// - Parameters:
    ///   - date: 回答日時
    ///   - questionId: 問題識別子
    ///   - answerTimeSeconds: 回答時間（秒）
    ///   - isCorrect: 正解したか
    ///   - isTimeout: 時間切れか
    init(date: Date = Date(), 
         questionId: String, 
         answerTimeSeconds: Double, 
         isCorrect: Bool, 
         isTimeout: Bool = false) {
        self.date = date
        self.questionId = questionId
        self.answerTimeSeconds = answerTimeSeconds
        self.isCorrect = isCorrect
        self.isTimeout = isTimeout
    }
    
    /// 問題ごとの平均回答時間を取得
    /// - Parameters:
    ///   - context: モデルコンテキスト
    /// - Returns: 問題ID：平均回答時間（秒）の辞書
    static func getAverageAnswerTimes(context: ModelContext) -> [String: Double] {
        let descriptor = FetchDescriptor<AnswerTimeRecord>()
        
        do {
            let records = try context.fetch(descriptor)
            var sumDict: [String: Double] = [:]
            var countDict: [String: Int] = [:]
            
            // 各問題ごとの合計時間と回数を計算
            for record in records {
                // 時間切れの場合は統計から除外
                if record.isTimeout { continue }
                
                sumDict[record.questionId, default: 0] += record.answerTimeSeconds
                countDict[record.questionId, default: 0] += 1
            }
            
            // 平均を計算
            var averageDict: [String: Double] = [:]
            for (questionId, sum) in sumDict {
                if let count = countDict[questionId], count > 0 {
                    averageDict[questionId] = sum / Double(count)
                }
            }
            
            return averageDict
        } catch {
            print("平均回答時間の取得に失敗: \(error)")
            return [:]
        }
    }
    
    /// 直近の回答時間記録を取得
    /// - Parameters:
    ///   - limit: 取得する記録の最大数
    ///   - context: モデルコンテキスト
    /// - Returns: 回答時間記録の配列（日付降順）
    static func getRecentRecords(limit: Int, context: ModelContext) -> [AnswerTimeRecord] {
        var descriptor = FetchDescriptor<AnswerTimeRecord>()
        descriptor.sortBy = [SortDescriptor(\.date, order: .reverse)]
        descriptor.fetchLimit = limit
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("回答時間記録の取得に失敗: \(error)")
            return []
        }
    }
    
    /// 指定された問題の平均回答時間を取得
    /// - Parameters:
    ///   - questionId: 問題識別子
    ///   - context: モデルコンテキスト
    /// - Returns: 平均回答時間（秒）、記録がない場合はnil
    static func getAverageTimeForQuestion(_ questionId: String, context: ModelContext) -> Double? {
        let predicate = #Predicate<AnswerTimeRecord> {
            $0.questionId == questionId && !$0.isTimeout
        }
        
        let descriptor = FetchDescriptor<AnswerTimeRecord>(predicate: predicate)
        
        do {
            let records = try context.fetch(descriptor)
            if records.isEmpty { return nil }
            
            let totalTime = records.reduce(0) { $0 + $1.answerTimeSeconds }
            return totalTime / Double(records.count)
        } catch {
            print("問題の平均回答時間の取得に失敗: \(error)")
            return nil
        }
    }
    
    /// 日別の平均回答時間を取得
    /// - Parameters:
    ///   - days: 過去何日分のデータを取得するか
    ///   - context: モデルコンテキスト
    /// - Returns: 日付と平均回答時間のタプル配列
    static func getDailyAverages(days: Int, context: ModelContext) -> [(date: Date, average: Double)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -(days - 1), to: today) else {
            return []
        }
        
        let predicate = #Predicate<AnswerTimeRecord> {
            $0.date >= startDate && !$0.isTimeout
        }
        
        let descriptor = FetchDescriptor<AnswerTimeRecord>(predicate: predicate)
        
        do {
            let records = try context.fetch(descriptor)
            var dailySums: [Date: Double] = [:]
            var dailyCounts: [Date: Int] = [:]
            
            // 日付ごとにグループ化
            for record in records {
                let dayStart = calendar.startOfDay(for: record.date)
                dailySums[dayStart, default: 0] += record.answerTimeSeconds
                dailyCounts[dayStart, default: 0] += 1
            }
            
            // 平均を計算して日付でソート
            let dailyAverages = dailySums.compactMap { (date, sum) -> (date: Date, average: Double)? in
                guard let count = dailyCounts[date], count > 0 else { return nil }
                return (date: date, average: sum / Double(count))
            }.sorted { $0.date < $1.date }
            
            return dailyAverages
        } catch {
            print("日別平均回答時間の取得に失敗: \(error)")
            return []
        }
    }
}