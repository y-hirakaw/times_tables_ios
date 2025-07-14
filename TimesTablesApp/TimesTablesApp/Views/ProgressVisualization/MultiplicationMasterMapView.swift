//
//  MultiplicationMasterMapView.swift
//  TimesTablesApp
//
//  Created by Claude Code on 2025/07/13.
//

import SwiftUI

/// テーブル選択のためのIdentifiableな構造体
struct TableSelection: Identifiable {
    let id: Int
    let table: Int
    
    init(table: Int) {
        self.id = table
        self.table = table
    }
}

/// 九九マスターマップのビュー
/// 1〜9の段を島や城で視覚的に表現
struct MultiplicationMasterMapView: View {
    @Environment(\.dataStore) private var dataStore
    @State private var progressViewState = ProgressVisualizationViewState()
    @State private var selectedTable: TableSelection? = nil
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            // コンパクトヘッダー
            HStack {
                Text("九九マスターマップ")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text("\(progressViewState.masterCount)/9")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
            
            // データがロード中の場合はローディング表示
            if progressViewState.isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("データを読み込み中...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .frame(height: 120)
            } else {
                // コンパクトマップグリッド
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(1...9, id: \.self) { table in
                        CompactTableIslandView(
                            table: table,
                            progressViewState: progressViewState
                        )
                        .onTapGesture {
                            selectedTable = TableSelection(table: table)
                        }
                    }
                }
                
                // コンパクト励ましメッセージ
                Text(progressViewState.getEncouragementMessage())
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .onAppear {
            progressViewState.setDataStore(dataStore)
            // 画面が表示されるたびにデータを更新
            progressViewState.refreshAllData()
        }
        .refreshable {
            // プルして更新
            progressViewState.refreshAllData()
        }
        .sheet(item: $selectedTable) { tableSelection in
            TableDetailView(
                table: tableSelection.table,
                progressViewState: progressViewState
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
}

/// 各段を表す島のビュー（フルサイズ）
private struct TableIslandView: View {
    let table: Int
    let progressViewState: ProgressVisualizationViewState
    
    var body: some View {
        let (title, subtitle, color) = progressViewState.getDisplayDataFor(table: table)
        let (level, progress) = progressViewState.getMasteryStatusFor(table: table)
        
        
        VStack(spacing: 8) {
            // 島/城のアイコン
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Circle()
                    .stroke(color, lineWidth: 3)
                    .frame(width: 80, height: 80)
                
                VStack {
                    Image(systemName: level == .master ? "crown.fill" : "mountain.2.fill")
                        .font(.title2)
                        .foregroundColor(color)
                    
                    Text("\(table)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                }
            }
            
            // 段名
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            
            // 習熟度表示
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // 進捗バー
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .frame(width: 60)
        }
        .padding(8)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

/// コンパクトな段ビュー
private struct CompactTableIslandView: View {
    let table: Int
    let progressViewState: ProgressVisualizationViewState
    
    var body: some View {
        let (_, _, color) = progressViewState.getDisplayDataFor(table: table)
        let (level, progress) = progressViewState.getMasteryStatusFor(table: table)
        
        VStack(spacing: 4) {
            // コンパクトなアイコン
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Circle()
                    .stroke(color, lineWidth: 2)
                    .frame(width: 50, height: 50)
                
                VStack(spacing: 2) {
                    Image(systemName: level == .master ? "crown.fill" : "mountain.2.fill")
                        .font(.caption)
                        .foregroundColor(color)
                    
                    Text("\(table)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                }
            }
            
            // コンパクト進捗バー
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .frame(width: 40, height: 4)
        }
        .padding(6)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}

/// 段の詳細ビュー
private struct TableDetailView: View {
    let table: Int
    @Bindable var progressViewState: ProgressVisualizationViewState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // モーダル表示時にデータを再取得
                    let progress = progressViewState.getProgressFor(table: table)
                    let (title, subtitle, color) = progressViewState.getDisplayDataFor(table: table)
                    
                    // ヘッダー
                    VStack {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.2))
                            .frame(width: 120, height: 120)
                        
                        VStack {
                            Image(systemName: progress?.masteryLevel == .master ? "crown.fill" : "mountain.2.fill")
                                .font(.largeTitle)
                                .foregroundColor(color)
                            
                            Text("\(table)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(color)
                        }
                    }
                    
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // 統計情報
                VStack(spacing: 16) {
                    if let progress = progress {
                        StatisticRowView(
                            icon: "checkmark.circle.fill",
                            title: "せいかいりつ",
                            value: "\(Int(progress.correctRate * 100))%",
                            color: color
                        )
                        
                        StatisticRowView(
                            icon: "questionmark.circle.fill",
                            title: "といた もんだい",
                            value: "\(progress.totalProblems)もん",
                            color: color
                        )
                        
                        if progress.masteryLevel != .master {
                            StatisticRowView(
                                icon: "target",
                                title: "マスターまで",
                                value: "あと\(progress.problemsToMaster)もん",
                                color: color
                            )
                        }
                    } else {
                        // データがない場合の表示
                        Text("まだこの段の問題を\nといていません")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("\(table)のだん")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("とじる") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// 統計行ビュー
private struct StatisticRowView: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }
}

#Preview {
    MultiplicationMasterMapView()
        .environment(\.dataStore, DataStore.shared)
}