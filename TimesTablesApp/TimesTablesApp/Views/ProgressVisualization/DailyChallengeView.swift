//
//  DailyChallengeView.swift
//  TimesTablesApp
//
//  Created by Claude Code on 2025/07/13.
//

import SwiftUI

/// デイリーチャレンジのビュー
/// 今日の目標と進捗を表示
struct DailyChallengeView: View {
    @Environment(\.dataStore) private var dataStore
    @State private var progressViewState = ProgressVisualizationViewState()
    @State private var showCelebration = false
    
    var body: some View {
        VStack(spacing: 12) {
            // コンパクトチャレンジヘッダー
            HStack {
                Image(systemName: "target")
                    .foregroundColor(.blue)
                    .font(.headline)
                
                Text(NSLocalizedString("daily_challenge_title", comment: "きょうのチャレンジ"))
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                Spacer()
                
                if let challenge = progressViewState.todayChallenge {
                    if challenge.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.subheadline)
                    } else {
                        Text("\(challenge.completedProblems)/\(challenge.targetProblems)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // コンパクトチャレンジ内容
            if let challenge = progressViewState.todayChallenge {
                // コンパクトプログレスバー
                VStack(spacing: 6) {
                    ProgressView(value: challenge.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: challenge.isCompleted ? .green : .blue))
                        .frame(height: 6)
                    
                    // コンパクトステータスメッセージ
                    if challenge.isCompleted {
                        Text(NSLocalizedString("daily_challenge_completed", comment: "きょうのもくひょう たっせい！"))
                            .font(.caption)
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                    } else {
                        let remaining = challenge.targetProblems - challenge.completedProblems
                        Text(String(format: NSLocalizedString("daily_challenge_remaining", comment: "あと %ldもん がんばろう！"), remaining))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // 連続達成記録
            if progressViewState.currentStreak > 0 {
                StreakDisplayView(streak: progressViewState.currentStreak)
            }
            
            // 週間履歴
            WeeklyHistoryView(weeklyHistory: progressViewState.weeklyHistory)
        }
        .onAppear {
            progressViewState.setDataStore(dataStore)
        }
        .onChange(of: progressViewState.todayChallenge?.isCompleted) { oldValue, newValue in
            if newValue == true && oldValue == false {
                showCelebration = true
            }
        }
        .alert(NSLocalizedString("daily_challenge_congratulations", comment: "おめでとう！"), isPresented: $showCelebration) {
            Button(NSLocalizedString("daily_challenge_thanks", comment: "ありがとう！")) { }
        } message: {
            Text(NSLocalizedString("daily_challenge_completed_message", comment: "きょうのチャレンジをたっせいしました！\nすばらしいです！"))
        }
    }
}

/// 連続達成記録ビュー
private struct StreakDisplayView: View {
    let streak: Int
    
    var body: some View {
        HStack {
            Image(systemName: "flame.fill")
                .foregroundColor(.orange)
                .font(.title3)
            
            Text(String(format: NSLocalizedString("daily_challenge_streak", comment: "れんぞく %ldにち"), streak))
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            ForEach(0..<min(streak, 7), id: \.self) { _ in
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
            }
            
            if streak > 7 {
                Text("+\(streak - 7)")
                    .font(.caption)
                    .foregroundColor(.yellow)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// 週間履歴ビュー
private struct WeeklyHistoryView: View {
    let weeklyHistory: [DailyChallenge]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("daily_challenge_recent_efforts", comment: "さいきんの がんばり"))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                ForEach(pastSevenDays(), id: \.self) { date in
                    let dayChallenge = weeklyHistory.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
                    
                    VStack(spacing: 4) {
                        Text(dayOfWeekString(for: date))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Rectangle()
                            .fill(dayChallenge?.isCompleted == true ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 32, height: 32)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(
                                Group {
                                    if let challenge = dayChallenge {
                                        if challenge.isCompleted {
                                            Image(systemName: "checkmark")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                        } else if challenge.completedProblems > 0 {
                                            Text("\(challenge.completedProblems)")
                                                .font(.caption2)
                                                .foregroundColor(.primary)
                                        }
                                    }
                                }
                            )
                    }
                }
                
                Spacer()
            }
        }
    }
    
    private func pastSevenDays() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<7).compactMap { daysAgo in
            calendar.date(byAdding: .day, value: -daysAgo, to: today)
        }.reversed()
    }
    
    private func dayOfWeekString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

#Preview {
    DailyChallengeView()
        .environment(\.dataStore, DataStore.shared)
        .padding()
}