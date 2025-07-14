//
//  CommunicationViewState.swift
//  TimesTablesApp
//
//  Created by Claude Code on 2025/07/13.
//

import Foundation
import SwiftUI
import SwiftData
import AVFoundation

/// 親子間コミュニケーション機能の状態管理
@MainActor
@Observable
class CommunicationViewState: NSObject {
    /// メッセージ一覧
    var messages: [Message] = []
    
    /// 最近の達成一覧
    var recentAchievements: [Achievement] = []
    
    /// 未読メッセージ数（子供向け）
    var unreadMessagesForChild: Int = 0
    
    /// 未読メッセージ数（親向け）
    var unreadMessagesForParent: Int = 0
    
    /// ローディング状態
    var isLoading: Bool = false
    
    /// 音声録音・再生関連
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var isRecording: Bool = false
    var isPlaying: Bool = false
    var recordingDuration: TimeInterval = 0
    
    /// データストアの参照
    private weak var dataStore: DataStore?
    
    /// 録音タイマー
    private var recordingTimer: Timer?
    
    override init() {
        super.init()
    }
    
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
            // メッセージを取得
            messages = Message.getRecentMessages(context: dataStore.context)
            
            // 達成を取得
            recentAchievements = Achievement.getRecentAchievements(context: dataStore.context)
            
            // 未読数を更新
            unreadMessagesForChild = Message.getUnreadCount(for: .child, context: dataStore.context)
            unreadMessagesForParent = Message.getUnreadCount(for: .parent, context: dataStore.context)
            
            isLoading = false
        }
    }
    
    // MARK: - メッセージ送受信
    
    /// テキストメッセージを送信
    func sendTextMessage(content: String, sender: MessageSender) {
        guard let dataStore = dataStore else { return }
        
        let message = Message.createParentMessage(
            content: content,
            context: dataStore.context
        )
        
        messages.insert(message, at: 0)
        refreshUnreadCounts()
    }
    
    /// 音声メッセージの録音を開始
    func startRecording() {
        guard !isRecording else { return }
        
        // 録音権限をリクエスト
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] allowed in
            DispatchQueue.main.async {
                if allowed {
                    self?.setupAndStartRecording()
                }
            }
        }
    }
    
    /// 録音を停止
    func stopRecording() {
        guard isRecording else { return }
        
        audioRecorder?.stop()
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        // 録音完了後の処理
        if let audioURL = audioRecorder?.url {
            saveAudioMessage(audioURL: audioURL)
        }
    }
    
    /// 音声再生を開始
    func playAudio(from message: Message) {
        guard let audioFilePath = message.audioFilePath,
              let audioURL = URL(string: audioFilePath) else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("音声再生エラー: \(error)")
        }
    }
    
    /// 音声再生を停止
    func stopAudio() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    // MARK: - 学習報告
    
    /// 学習セッションの報告を送信
    func sendStudyReport(
        totalProblems: Int,
        correctAnswers: Int,
        averageTime: Double,
        completedChallenges: [String] = [],
        newMasteries: [Int] = []
    ) {
        guard let dataStore = dataStore else { return }
        
        let sessionData = StudySessionData(
            totalProblems: totalProblems,
            correctAnswers: correctAnswers,
            averageTime: averageTime,
            completedChallenges: completedChallenges,
            newMasteries: newMasteries
        )
        
        let message = Message.createStudyReport(
            sessionData: sessionData,
            context: dataStore.context
        )
        
        messages.insert(message, at: 0)
        refreshUnreadCounts()
    }
    
    /// 達成を親に報告
    func shareAchievement(_ achievement: Achievement) {
        guard let dataStore = dataStore else { return }
        
        let message = Message.createAchievementMessage(
            achievement: achievement.title,
            achievementId: achievement.id,
            context: dataStore.context
        )
        
        achievement.markAsShared(context: dataStore.context)
        messages.insert(message, at: 0)
        refreshAchievements()
        refreshUnreadCounts()
    }
    
    // MARK: - 達成管理
    
    /// 新しい達成をチェック・作成
    func checkAndCreateAchievements(
        for questionId: String,
        isCorrect: Bool,
        answerTime: Double,
        currentStreak: Int,
        masteredTables: [Int]
    ) {
        guard let dataStore = dataStore else { return }
        
        var newAchievements: [Achievement] = []
        
        // 段マスター達成をチェック
        for table in masteredTables {
            let existing = Achievement.getAchievements(of: .tableMastery, context: dataStore.context)
            let alreadyHas = existing.contains { achievement in
                achievement.metadata?["table"] == "\(table)"
            }
            
            if !alreadyHas {
                let achievement = Achievement.createTableMasteryAchievement(
                    table: table,
                    context: dataStore.context
                )
                newAchievements.append(achievement)
            }
        }
        
        // 連続達成記録をチェック
        if currentStreak > 0 && currentStreak % 3 == 0 { // 3の倍数で記録
            let achievement = Achievement.createStreakAchievement(
                streak: currentStreak,
                context: dataStore.context
            )
            newAchievements.append(achievement)
        }
        
        // 速度記録をチェック（今回は簡略化）
        
        // 新しい達成があれば一覧を更新
        if !newAchievements.isEmpty {
            refreshAchievements()
        }
    }
    
    /// デイリーチャレンジ達成を報告
    func reportDailyChallengeCompletion(targetProblems: Int, completedProblems: Int) {
        guard let dataStore = dataStore else { return }
        
        let achievement = Achievement.createDailyChallengeAchievement(
            targetProblems: targetProblems,
            completedProblems: completedProblems,
            context: dataStore.context
        )
        
        recentAchievements.insert(achievement, at: 0)
    }
    
    // MARK: - 既読管理
    
    /// メッセージを既読にする
    func markMessageAsRead(_ message: Message) {
        guard let dataStore = dataStore else { return }
        
        message.markAsRead(context: dataStore.context)
        refreshUnreadCounts()
    }
    
    /// 指定送信者の全メッセージを既読にする
    func markAllMessagesAsRead(for recipient: MessageSender) {
        guard let dataStore = dataStore else { return }
        
        Message.markAllAsRead(for: recipient, context: dataStore.context)
        refreshUnreadCounts()
    }
    
    // MARK: - プライベートメソッド
    
    private func setupAndStartRecording() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            
            // 録音ファイルのURL
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioURL = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
            
            // 録音設定
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.record()
            isRecording = true
            recordingDuration = 0
            
            // 録音時間更新タイマー
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.recordingDuration += 0.1
                
                // 最大30秒で自動停止
                if self?.recordingDuration ?? 0 >= 30.0 {
                    self?.stopRecording()
                }
            }
            
        } catch {
            print("録音開始エラー: \(error)")
        }
    }
    
    private func saveAudioMessage(audioURL: URL) {
        guard let dataStore = dataStore else { return }
        
        let message = Message.createParentMessage(
            content: "おんせいメッセージ (\(String(format: "%.1f", recordingDuration))びょう)",
            audioFilePath: audioURL.absoluteString,
            context: dataStore.context
        )
        
        messages.insert(message, at: 0)
        refreshUnreadCounts()
    }
    
    private func refreshUnreadCounts() {
        guard let dataStore = dataStore else { return }
        
        unreadMessagesForChild = Message.getUnreadCount(for: .child, context: dataStore.context)
        unreadMessagesForParent = Message.getUnreadCount(for: .parent, context: dataStore.context)
    }
    
    private func refreshAchievements() {
        guard let dataStore = dataStore else { return }
        
        recentAchievements = Achievement.getRecentAchievements(context: dataStore.context)
    }
    
    // MARK: - 事前定義メッセージ
    
    /// 親から子への励ましメッセージテンプレート
    func getEncouragementTemplates() -> [String] {
        return [
            NSLocalizedString("がんばったね！", comment: "You did great!"),
            NSLocalizedString("すごいじゃない！", comment: "That's amazing!"),
            NSLocalizedString("よくできました！", comment: "Well done!"),
            NSLocalizedString("その ちょうしで がんばって！", comment: "Keep up that good work!"),
            NSLocalizedString("まいにち べんきょうして えらいね！", comment: "Great job studying every day!"),
            NSLocalizedString("だんだん じょうずに なってるよ！", comment: "You're getting better and better!"),
            NSLocalizedString("つぎも がんばろうね！", comment: "Let's keep working hard!"),
            NSLocalizedString("とても じょうずですよ！", comment: "You're doing very well!")
        ]
    }
    
    /// クイック返信メッセージ
    func sendQuickReply(_ template: String) {
        sendTextMessage(content: template, sender: .parent)
    }
}

// MARK: - AVAudioPlayerDelegate

extension CommunicationViewState: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            isPlaying = false
        }
    }
}