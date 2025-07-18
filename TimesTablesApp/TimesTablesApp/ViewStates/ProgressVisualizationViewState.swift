//
//  ProgressVisualizationViewState.swift
//  TimesTablesApp
//
//  Created by Claude Code on 2025/07/13.
//

import Foundation
import SwiftUI
import SwiftData

/// 進捗可視化システムの状態管理
/// 九九マスターマップとデイリーチャレンジを管理
@MainActor
@Observable
class ProgressVisualizationViewState {
    /// 各段の習熟度進捗
    var masteryProgress: [MasteryProgress] = []
    
    /// 今日のデイリーチャレンジ
    var todayChallenge: DailyChallenge?
    
    /// 過去7日間のチャレンジ履歴
    var weeklyHistory: [DailyChallenge] = []
    
    /// 現在の連続達成記録
    var currentStreak: Int = 0
    
    /// マスターした段の数
    var masterCount: Int = 0
    
    /// 全体の平均正解率
    var overallCorrectRate: Double = 0.0
    
    /// ローディング状態
    var isLoading: Bool = false
    
    /// 進捗更新が必要かどうか
    var needsRefresh: Bool = true
    
    /// データストアの参照
    private weak var dataStore: DataStore?
    
    init() {}
    
    /// データストアを設定
    func setDataStore(_ dataStore: DataStore) {
        self.dataStore = dataStore
        refreshAllData()
    }
    
    /// 全てのデータを更新
    func refreshAllData() {
        guard let dataStore = dataStore else { return }
        
        isLoading = true
        
        Task {
            // 習熟度進捗を更新
            masteryProgress = MasteryProgress.getAllProgress(context: dataStore.context)
            
            // データが不足している場合は、1-9の段すべてのデータを確保
            if masteryProgress.count < 9 {
                var progressDict: [Int: MasteryProgress] = [:]
                for progress in masteryProgress {
                    progressDict[progress.multiplicationTable] = progress
                }
                
                // 不足している段のダミーデータを作成（表示用）
                for table in 1...9 {
                    if progressDict[table] == nil {
                        let dummyProgress = MasteryProgress(multiplicationTable: table)
                        masteryProgress.append(dummyProgress)
                    }
                }
                
                // 段番号順にソート
                masteryProgress.sort { $0.multiplicationTable < $1.multiplicationTable }
            }
            
            // 今日のチャレンジを取得
            todayChallenge = DailyChallenge.getTodaysChallenge(context: dataStore.context)
            
            // 週間履歴を取得
            weeklyHistory = DailyChallenge.getWeeklyHistory(context: dataStore.context)
            
            // 統計データを更新
            currentStreak = DailyChallenge.getCurrentStreak(context: dataStore.context)
            masterCount = MasteryProgress.getMasterCount(context: dataStore.context)
            overallCorrectRate = MasteryProgress.getOverallCorrectRate(context: dataStore.context)
            
            isLoading = false
            needsRefresh = false
        }
    }
    
    /// 特定の段の進捗を取得
    func getProgressFor(table: Int) -> MasteryProgress? {
        return masteryProgress.first { $0.multiplicationTable == table }
    }
    
    /// 問題回答時に呼ばれる進捗更新
    func updateProgressAfterAnswer(questionId: String, isCorrect: Bool) {
        guard let dataStore = dataStore else { return }
        
        print("ProgressVisualizationViewState.updateProgressAfterAnswer: questionId=\(questionId), isCorrect=\(isCorrect)")
        
        // 問題IDから段を抽出して進捗を更新
        let components = questionId.split(separator: "x")
        if components.count == 2,
           let left = Int(components[0]),
           let right = Int(components[1]) {
            
            print("ProgressVisualizationViewState.updateProgressAfterAnswer: 対象段=\(left), \(right)")
            
            // 両方の段の進捗を更新
            for table in [left, right] {
                if let progress = masteryProgress.first(where: { $0.multiplicationTable == table }) {
                    let oldTotal = progress.totalProblems
                    let oldCorrect = progress.correctProblems
                    progress.updateWithResult(isCorrect: isCorrect, context: dataStore.context)
                    print("ProgressVisualizationViewState.updateProgressAfterAnswer: \(table)の段 - \(oldTotal)→\(progress.totalProblems)問題, \(oldCorrect)→\(progress.correctProblems)正解")
                } else {
                    print("ProgressVisualizationViewState.updateProgressAfterAnswer: \(table)の段の進捗データが見つかりません")
                }
            }
            
            // デイリーチャレンジの進捗を更新
            todayChallenge?.updateProgress(additionalProblems: 1, context: dataStore.context)
            
            // 統計データを再計算
            masterCount = MasteryProgress.getMasterCount(context: dataStore.context)
            overallCorrectRate = MasteryProgress.getOverallCorrectRate(context: dataStore.context)
            
            // データ更新後に強制的に再取得
            Task {
                await MainActor.run {
                    refreshAllData()
                }
            }
        }
    }
    
    /// デイリーチャレンジの達成状況をチェック
    func checkDailyChallengeCompletion() -> Bool {
        return todayChallenge?.isCompleted ?? false
    }
    
    /// 段のマスター状況を取得
    func getMasteryStatusFor(table: Int) -> (level: MasteryLevel, progress: Double) {
        guard let progress = getProgressFor(table: table) else {
            return (.beginner, 0.0)
        }
        
        return (progress.masteryLevel, progress.correctRate)
    }
    
    /// 次にマスターに近い段を取得
    func getNextMasterCandidate() -> (table: Int, problemsNeeded: Int)? {
        let nonMasterProgress = masteryProgress.filter { $0.masteryLevel != .master }
        
        guard !nonMasterProgress.isEmpty else { return nil }
        
        let candidate = nonMasterProgress.min { $0.problemsToMaster < $1.problemsToMaster }
        
        if let candidate = candidate {
            return (candidate.multiplicationTable, candidate.problemsToMaster)
        }
        
        return nil
    }
    
    /// 段別の表示用データを取得
    func getDisplayDataFor(table: Int) -> (title: String, subtitle: String, color: Color) {
        let (level, progress) = getMasteryStatusFor(table: table)
        
        let title = "\(table)のだん"
        let subtitle: String
        let color: Color
        
        switch level {
        case .beginner:
            subtitle = NSLocalizedString("れんしゅうちゅう", tableName: "Gamification", comment: "Beginner level display")
            color = .red
        case .intermediate:
            subtitle = NSLocalizedString("がんばってる！", tableName: "Gamification", comment: "Intermediate level display")
            color = .orange
        case .advanced:
            subtitle = NSLocalizedString("もうすこし！", tableName: "Gamification", comment: "Advanced level display")
            color = .blue
        case .master:
            subtitle = NSLocalizedString("マスター✨", tableName: "Gamification", comment: "Master level display")
            color = .green
        }
        
        return (title, subtitle, color)
    }
    
    /// 励ましメッセージを生成
    func getEncouragementMessage() -> String {
        if masterCount == 9 {
            return NSLocalizedString("すべての だん を マスター！ すごいね！", tableName: "Questions", comment: "All tables mastered message")
        } else if masterCount >= 6 {
            return NSLocalizedString("もうすこしで かんぺき だね！", tableName: "Questions", comment: "Almost perfect message")
        } else if currentStreak >= 3 {
            return String(format: NSLocalizedString("れんぞく %lldにち", tableName: "Gamification", comment: "Consecutive days streak"), currentStreak) + NSLocalizedString(" がんばってるね！", comment: "Keep it up message")
        } else if let (table, problems) = getNextMasterCandidate() {
            return String(format: NSLocalizedString("%lldのだん", comment: "Times table number"), table) + NSLocalizedString(" まで ", comment: " until ") + String(format: NSLocalizedString("あと %lldもん がんばろう！", tableName: "Questions", comment: "More problems to go"), problems)
        } else {
            return NSLocalizedString("きょうも がんばろう！", tableName: "Gamification", comment: "Let's do our best today")
        }
    }
    
    /// データ更新が必要な場合のフラグを設定
    func markForRefresh() {
        needsRefresh = true
    }
}