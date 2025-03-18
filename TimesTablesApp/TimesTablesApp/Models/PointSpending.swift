import Foundation
import SwiftData

/// ポイント消費履歴を記録するモデル
@Model
final class PointSpending {
    /// 消費日時
    var date: Date
    /// 消費ポイント
    var pointsSpent: Int
    /// 消費理由
    var reason: String
    
    init(date: Date, pointsSpent: Int, reason: String) {
        self.date = date
        self.pointsSpent = pointsSpent
        self.reason = reason
    }
    
    /// 全てのポイント消費履歴を取得
    /// - Parameter context: モデルコンテキスト
    /// - Returns: ポイント消費履歴の配列（日付降順）
    static func getAllSpendingHistory(context: ModelContext) -> [PointSpending] {
        var descriptor = FetchDescriptor<PointSpending>()
        descriptor.sortBy = [SortDescriptor(\.date, order: .reverse)]
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching point spending history: \(error)")
            return []
        }
    }
}
