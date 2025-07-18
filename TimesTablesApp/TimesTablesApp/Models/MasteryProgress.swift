//
//  MasteryProgress.swift
//  TimesTablesApp
//
//  Created by Claude Code on 2025/07/13.
//

import Foundation
import SwiftData

/// 九九の習熟度レベル
enum MasteryLevel: String, CaseIterable, Codable {
    case beginner = "beginner"      // 初心者（0-25%）
    case intermediate = "intermediate" // 中級者（26-60%）
    case advanced = "advanced"      // 上級者（61-85%）
    case master = "master"         // マスター（86-100%）
    
    /// 習熟度に応じた表示用文字列
    var displayName: String {
        switch self {
        case .beginner:
            return NSLocalizedString("れんしゅうちゅう", tableName: "Gamification", comment: "Beginner level")
        case .intermediate:
            return NSLocalizedString("がんばってる", tableName: "Gamification", comment: "Intermediate level")
        case .advanced:
            return NSLocalizedString("もうすこし", tableName: "Gamification", comment: "Advanced level")
        case .master:
            return NSLocalizedString("マスター", tableName: "Gamification", comment: "Master level")
        }
    }
    
    /// 習熟度に応じた色
    var color: String {
        switch self {
        case .beginner:
            return "red"
        case .intermediate:
            return "orange"
        case .advanced:
            return "blue"
        case .master:
            return "green"
        }
    }
    
    /// 正解率から習熟度を判定
    static func from(correctRate: Double) -> MasteryLevel {
        switch correctRate {
        case 0.0..<0.26:
            return .beginner
        case 0.26..<0.61:
            return .intermediate
        case 0.61..<0.86:
            return .advanced
        default:
            return .master
        }
    }
}

/// 九九の段ごとの習熟度進捗を管理するモデル
@Model
class MasteryProgress {
    /// 対象の段（1-9）
    var multiplicationTable: Int
    
    /// これまでに解いた総問題数
    var totalProblems: Int
    
    /// 正解した問題数
    var correctProblems: Int
    
    /// 習熟度レベル
    var masteryLevel: MasteryLevel {
        return MasteryLevel.from(correctRate: correctRate)
    }
    
    /// 正解率
    var correctRate: Double {
        guard totalProblems > 0 else { return 0.0 }
        return Double(correctProblems) / Double(totalProblems)
    }
    
    /// マスターになるまでに必要な問題数の推定
    var problemsToMaster: Int {
        // マスターレベル（86%）に必要な正解数を計算
        let targetCorrectRate = 0.86
        let requiredCorrectProblems = Int(ceil(Double(totalProblems) * targetCorrectRate))
        let remainingCorrectProblems = max(0, requiredCorrectProblems - correctProblems)
        
        // 現在の正解率を考慮して必要な追加問題数を推定
        let currentCorrectRate = max(correctRate, 0.5) // 最低50%と仮定
        return Int(ceil(Double(remainingCorrectProblems) / currentCorrectRate))
    }
    
    /// 最後に更新された日時
    var lastUpdated: Date
    
    init(multiplicationTable: Int) {
        self.multiplicationTable = multiplicationTable
        self.totalProblems = 0
        self.correctProblems = 0
        self.lastUpdated = Date()
    }
}

extension MasteryProgress {
    /// 特定の段の進捗を取得（存在しない場合は作成）
    static func getProgress(for table: Int, context: ModelContext) -> MasteryProgress {
        let descriptor = FetchDescriptor<MasteryProgress>(
            predicate: #Predicate<MasteryProgress> { progress in
                progress.multiplicationTable == table
            }
        )
        
        print("MasteryProgress.getProgress: \(table)の段を検索中...")
        if let existingProgress = try? context.fetch(descriptor).first {
            print("MasteryProgress.getProgress: \(table)の段の既存データを発見 - 総問題数: \(existingProgress.totalProblems), 正解数: \(existingProgress.correctProblems)")
            return existingProgress
        }
        
        // 新しい進捗を作成
        print("MasteryProgress.getProgress: \(table)の段の新規データを作成")
        let newProgress = MasteryProgress(multiplicationTable: table)
        context.insert(newProgress)
        
        do {
            try context.save()
            print("MasteryProgress.getProgress: \(table)の段の新規データ保存成功")
        } catch {
            print("MasteryProgress.getProgress: \(table)の段の新規データ保存エラー - \(error)")
        }
        
        return newProgress
    }
    
    /// 全ての段の進捗を取得
    static func getAllProgress(context: ModelContext) -> [MasteryProgress] {
        let descriptor = FetchDescriptor<MasteryProgress>(
            sortBy: [SortDescriptor(\.multiplicationTable, order: .forward)]
        )
        
        let existingProgress = (try? context.fetch(descriptor)) ?? []
        print("MasteryProgress.getAllProgress: 既存データ数=\(existingProgress.count)")
        
        // 不足している段の進捗を作成
        var progressDict: [Int: MasteryProgress] = [:]
        for progress in existingProgress {
            progressDict[progress.multiplicationTable] = progress
            print("MasteryProgress.getAllProgress: \(progress.multiplicationTable)の段 - 総問題数: \(progress.totalProblems), 正解数: \(progress.correctProblems), 正解率: \(progress.correctRate)")
        }
        
        var needsSave = false
        for table in 1...9 {
            if progressDict[table] == nil {
                print("MasteryProgress.getAllProgress: \(table)の段の新規データを作成")
                let newProgress = MasteryProgress(multiplicationTable: table)
                context.insert(newProgress)
                progressDict[table] = newProgress
                needsSave = true
            }
        }
        
        if needsSave {
            do {
                try context.save()
                print("MasteryProgress.getAllProgress: 新規データ保存成功")
            } catch {
                print("MasteryProgress.getAllProgress: 新規データ保存エラー - \(error)")
            }
        }
        
        return (1...9).compactMap { progressDict[$0] }
    }
    
    /// 問題の回答結果で進捗を更新
    func updateWithResult(isCorrect: Bool, context: ModelContext) {
        let oldTotal = totalProblems
        let oldCorrect = correctProblems
        
        totalProblems += 1
        if isCorrect {
            correctProblems += 1
        }
        lastUpdated = Date()
        
        print("MasteryProgress更新: \(multiplicationTable)の段 - \(oldTotal)→\(totalProblems)問題, \(oldCorrect)→\(correctProblems)正解, 正解率: \(correctRate)")
        
        do {
            try context.save()
            print("MasteryProgress保存成功: \(multiplicationTable)の段")
        } catch {
            print("MasteryProgress保存エラー: \(multiplicationTable)の段 - \(error)")
        }
    }
    
    /// 既存のAnswerTimeRecordから進捗を再計算
    static func recalculateAllProgress(context: ModelContext) {
        // 全ての回答記録を取得
        let answerDescriptor = FetchDescriptor<AnswerTimeRecord>()
        let allAnswers = (try? context.fetch(answerDescriptor)) ?? []
        
        // 段ごとにグループ化して統計を計算
        var tableStats: [Int: (total: Int, correct: Int)] = [:]
        
        for answer in allAnswers {
            // 問題識別子から段を抽出（例："3x4" -> [3, 4]）
            let components = answer.questionId.split(separator: "x")
            if components.count == 2,
               let left = Int(components[0]),
               let right = Int(components[1]) {
                
                // 両方の段で統計を更新
                for table in [left, right] {
                    if tableStats[table] == nil {
                        tableStats[table] = (total: 0, correct: 0)
                    }
                    tableStats[table]!.total += 1
                    if answer.isCorrect {
                        tableStats[table]!.correct += 1
                    }
                }
            }
        }
        
        // 進捗を更新
        for table in 1...9 {
            let progress = getProgress(for: table, context: context)
            if let stats = tableStats[table] {
                progress.totalProblems = stats.total
                progress.correctProblems = stats.correct
                progress.lastUpdated = Date()
            }
        }
        
        try? context.save()
    }
    
    /// マスターした段の数を取得
    static func getMasterCount(context: ModelContext) -> Int {
        let allProgress = getAllProgress(context: context)
        return allProgress.filter { $0.masteryLevel == .master }.count
    }
    
    /// 全体の平均正解率を取得
    static func getOverallCorrectRate(context: ModelContext) -> Double {
        let allProgress = getAllProgress(context: context)
        let totalProblems = allProgress.reduce(0) { $0 + $1.totalProblems }
        let totalCorrect = allProgress.reduce(0) { $0 + $1.correctProblems }
        
        guard totalProblems > 0 else { return 0.0 }
        return Double(totalCorrect) / Double(totalProblems)
    }
}