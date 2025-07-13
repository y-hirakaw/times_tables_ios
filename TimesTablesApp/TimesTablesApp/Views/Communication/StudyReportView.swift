//
//  StudyReportView.swift
//  TimesTablesApp
//
//  Created by Claude Code on 2025/07/13.
//

import SwiftUI

/// 学習報告ビュー（子供から親へ）
struct StudyReportView: View {
    @Environment(\.dataStore) private var dataStore
    @Environment(\.dismiss) private var dismiss
    @State private var communicationViewState = CommunicationViewState()
    @State private var showingSendConfirmation = false
    
    let totalProblems: Int
    let correctAnswers: Int
    let averageTime: Double
    let newMasteries: [Int]
    
    var correctRate: Int {
        guard totalProblems > 0 else { return 0 }
        return Int((Double(correctAnswers) / Double(totalProblems)) * 100)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // ヘッダー
                VStack(spacing: 12) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.pink)
                    
                    Text("きょうの がんばり")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("ほごしゃのひとに おしらせしよう！")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // 学習結果カード
                VStack(spacing: 16) {
                    resultCard(
                        icon: "questionmark.circle.fill",
                        title: "といた もんだい",
                        value: "\(totalProblems)もん",
                        color: .blue
                    )
                    
                    resultCard(
                        icon: "checkmark.circle.fill",
                        title: "せいかい",
                        value: "\(correctAnswers)もん",
                        color: .green
                    )
                    
                    resultCard(
                        icon: "percent",
                        title: "せいかいりつ",
                        value: "\(correctRate)%",
                        color: correctRate >= 80 ? .green : correctRate >= 60 ? .orange : .red
                    )
                    
                    resultCard(
                        icon: "clock.fill",
                        title: "へいきん じかん",
                        value: "\(String(format: "%.1f", averageTime))びょう",
                        color: .purple
                    )
                    
                    // 新しくマスターした段
                    if !newMasteries.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.yellow)
                                Text("あたらしく マスターしたもの")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(newMasteries, id: \.self) { table in
                                    Text("\(table)のだん")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.yellow)
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 8)
                                        .background(Color.yellow.opacity(0.2))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                Spacer()
                
                // 送信ボタン
                Button(action: sendReport) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("ほごしゃに おしらせする")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [.pink, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .pink.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
            .padding()
            .navigationTitle("がんばりレポート")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("とじる") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                communicationViewState.setDataStore(dataStore)
            }
            .alert("おくりました！", isPresented: $showingSendConfirmation) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("ほごしゃのひとに きょうの がんばりを おしらせしました！")
            }
        }
    }
    
    private func resultCard(icon: String, title: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Spacer()
        }
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func sendReport() {
        communicationViewState.sendStudyReport(
            totalProblems: totalProblems,
            correctAnswers: correctAnswers,
            averageTime: averageTime,
            newMasteries: newMasteries
        )
        
        showingSendConfirmation = true
    }
}

#Preview {
    StudyReportView(
        totalProblems: 10,
        correctAnswers: 8,
        averageTime: 4.2,
        newMasteries: [3, 7]
    )
    .environment(\.dataStore, DataStore.shared)
}