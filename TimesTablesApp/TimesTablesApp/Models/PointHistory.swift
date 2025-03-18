import Foundation
import SwiftData

/// ポイント獲得履歴を記録するモデル
@Model
final class PointHistory {
    /// 獲得日時
    var date: Date
    /// 獲得ポイント
    var pointsEarned: Int
    /// 問題識別子（オプション）
    var questionId: String?
    /// ボーナスポイントかどうか
    var isBonus: Bool
    
    init(date: Date, pointsEarned: Int, questionId: String? = nil, isBonus: Bool = false) {
        self.date = date
        self.pointsEarned = pointsEarned
        self.questionId = questionId
        self.isBonus = isBonus
    }
    
    /// 指定された日付の獲得ポイント合計を取得する
    /// - Parameters:
    ///   - date: 日付
    ///   - context: モデルコンテキスト
    /// - Returns: その日のポイント獲得合計
    static func getTotalPointsForDay(date: Date, context: ModelContext) -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<PointHistory> {
            $0.date >= startOfDay && $0.date < endOfDay
        }
        
        let descriptor = FetchDescriptor<PointHistory>(predicate: predicate)
        
        do {
            let records = try context.fetch(descriptor)
            return records.reduce(0) { $0 + $1.pointsEarned }
        } catch {
            print("Error fetching point history: \(error)")
            return 0
        }
    }
    
    /// 日別のポイント獲得合計を取得
    /// - Parameter context: モデルコンテキスト
    /// - Returns: 日付と獲得ポイント合計の辞書
    static func getDailyPointsSummary(context: ModelContext) -> [Date: Int] {
        let descriptor = FetchDescriptor<PointHistory>()
        
        do {
            let allRecords = try context.fetch(descriptor)
            let calendar = Calendar.current
            
            // 日付別にグループ化
            var dailyPoints = [Date: Int]()
            
            for record in allRecords {
                // 日付の時間部分を除去して日付のみにする
                let dayOnly = calendar.startOfDay(for: record.date)
                
                // その日のポイントを加算
                dailyPoints[dayOnly, default: 0] += record.pointsEarned
            }
            
            return dailyPoints
        } catch {
            print("Error fetching point history: \(error)")
            return [:]
        }
    }
}
