import SwiftUI
import SwiftData
import AVFoundation

/// メインの九九チャレンジ画面を表示するView
struct MultiplicationView: View {
    @StateObject private var viewState = MultiplicationViewState()
    @StateObject private var levelSystem = LevelSystemViewState()
    @Environment(\.dataStore) private var dataStore
    @Environment(\.soundManager) private var soundManager
    @StateObject private var badgeSystem: BadgeSystemViewState = BadgeSystemViewState(dataStore: DataStore.shared)
    @State private var showingPointsHistory = false
    @State private var showingQuestionSolving = false
    @State private var showingChildMessages = false
    @State private var showingBadgeCollection = false

    private let gradientBackground = LinearGradient(
        colors: [Color.themePrimary.opacity(0.3), Color.themePrimaryLight.opacity(0.2)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    private let buttonColors: [Color] = [
        .themePrimary, .themeSecondary, .themeWarning, .themePrimaryLight, 
        .themePrimaryDark, .themeError, .themeGold, .themeInfo, .themeSecondaryLight
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                gradientBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.spacing16) {
                        // ポイントとメイン操作ボタンを最上部に配置
                        VStack(spacing: Spacing.spacing12) {
                            // ポイント表示
                            pointsCard
                            
                            if viewState.question != nil {
                                // 問題が生成されたら専用画面に遷移することを表示
                                VStack(spacing: Spacing.spacing12) {
                                    Image(systemName: "arrow.up")
                                        .font(.system(size: 30))
                                        .foregroundColor(.themePrimary)
                                    
                                    Text("問題画面が開きます")
                                        .font(.themeSubheadline)
                                        .foregroundColor(.themeGray800)
                                }
                                .padding(Spacing.spacing16)
                                .cardStyle()
                            } else {
                                compactStartPrompt
                            }
                            
                            controlButtons
                        }
                        
                        // 進捗可視化システムをコンパクト表示
                        compactProgressSection
                        
                        // その他の要素
                        VStack(spacing: Spacing.spacing12) {
                            soundToggleButton
                            difficultQuestionsView
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("九九ティブ")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingChildMessages = true
                    } label: {
                        Label("メッセージ", systemImage: "message.circle")
                            .foregroundColor(.themePrimary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingBadgeCollection = true
                    } label: {
                        ZStack {
                            Image(systemName: "medal.fill")
                                .foregroundColor(.themeGold)
                            
                            // 新しいバッジがある場合は通知ドット
                            if !badgeSystem.newBadges.isEmpty {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 10, height: 10)
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewState.showParentDashboard()
                    } label: {
                        Label("ほごしゃ かんり がめん", systemImage: "person.circle")
                            .foregroundColor(.themePrimary)
                    }
                }
            }
            .onAppear {
                // DataStoreのコンテキストを設定
                viewState.updateModelContext(dataStore.context)
                // 最新データを読み込み
                viewState.refreshData()
            }
            .onChange(of: viewState.question) { _, newQuestion in
                // 問題が生成されたら専用画面を表示
                if newQuestion != nil {
                    showingQuestionSolving = true
                }
            }
            .sheet(isPresented: $viewState.showingPINAuth) {
                ParentAccessView(isAuthenticated: $viewState.isAuthenticated)
            }
            .sheet(isPresented: $viewState.showingTableSelection) {
                tableSelectionView
            }
            .fullScreenCover(isPresented: $viewState.isAuthenticated) {
                ParentDashboardView()
            }
            .fullScreenCover(isPresented: $showingQuestionSolving) {
                QuestionSolvingView(viewState: viewState)
            }
            .sheet(isPresented: $showingChildMessages) {
                ChildMessageView()
            }
            .sheet(isPresented: $showingBadgeCollection) {
                NavigationView {
                    BadgeCollectionView(badgeSystem: badgeSystem)
                }
            }
        }
        .overlay(
            // バッジ獲得通知
            Group {
                if badgeSystem.showingBadgeNotification, let latestBadge = badgeSystem.latestBadge {
                    BadgeNotificationView(
                        badgeType: latestBadge,
                        isPresented: $badgeSystem.showingBadgeNotification
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(2)
                }
            }
        )
        .overlay(
            // レベルアップアニメーション
            Group {
                if levelSystem.isLevelingUp, let levelUpInfo = levelSystem.levelUpInfo {
                    LevelUpAnimationView(
                        levelUpInfo: levelUpInfo,
                        isPresented: Binding<Bool>(
                            get: { levelSystem.isLevelingUp },
                            set: { levelSystem.isLevelingUp = $0 }
                        )
                    )
                }
            }
        )
        .onAppear {
            // レベルシステムをviewStateに設定
            viewState.setLevelSystem(levelSystem)
            
            // バッジシステムをviewStateに設定
            viewState.setBadgeSystem(badgeSystem)
            
            // レベルシステムの初期データを取得
            levelSystem.fetchUserLevel()
            
            // バッジシステムの初期データを取得
            badgeSystem.fetchEarnedBadges()
        }
    }
    
    private var compactProgressSection: some View {
        VStack(spacing: Spacing.spacing12) {
            // レベル表示
            LevelDisplayView()
                .cardStyle()
            
            // デイリーチャレンジをコンパクト表示
            DailyChallengeView()
                .cardStyle()
            
            // 九九マスターマップをコンパクト表示
            MultiplicationMasterMapView()
                .cardStyle()
                .id("MasterMap_\(viewState.getCurrentPoints())") // データ更新時に再描画
            
            // バッジシステムをコンパクト表示
            badgeCompactView
                .cardStyle()
        }
    }
    
    private var compactStartPrompt: some View {
        HStack {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 20))
                .foregroundColor(.themeGold)
            
            Text("ボタンをおして もんだいをやろう！")
                .font(.themeSubheadline)
                .foregroundColor(.themeGray800)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.spacing8)
        .cardStyle()
    }

    private var pointsCard: some View {
        Button(action: {
            showingPointsHistory = true
        }) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.themeGold)
                    .font(.themeTitle2)

                Text("ポイント: \(viewState.getCurrentPoints())")
                    .font(.themeTitle3)
                    .foregroundColor(.themeGray800)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.spacing8)
            .padding(.horizontal, Spacing.spacing16)
            .cardStyle()
        }
        .sheet(isPresented: $showingPointsHistory) {
            NavigationStack {
                PointHistoryView()
                    .navigationTitle("ポイントりれき")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("とじる") {
                                showingPointsHistory = false
                            }
                        }
                    }
            }
        }
    }


    private var startPrompt: some View {
        VStack(spacing: Spacing.spacing16) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 40))
                .foregroundColor(.themeGold)
                .padding(Spacing.spacing16)
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(ShadowStyle.small.opacity), 
                               radius: ShadowStyle.small.radius, 
                               x: ShadowStyle.small.x, 
                               y: ShadowStyle.small.y)
                )

            Text("ボタンをおして もんだいをやろう！")
                .font(.themeTitle2)
                .foregroundColor(.themeGray800)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.spacing16)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.spacing16)
        .cardStyle()
    }


    private var controlButtons: some View {
        VStack(spacing: Spacing.spacing16) {
            HStack(spacing: Spacing.spacing20) {
                Button(action: { viewState.startSequentialMode() }) {
                    HStack {
                        Image(systemName: "arrow.right")
                        Text("だんじゅんばん もんだい")
                    }
                    .primaryButtonStyle()
                }
                .disabled(viewState.isAnswering)
            }
            
            HStack(spacing: Spacing.spacing20) {
                Button(action: { viewState.generateRandomQuestion() }) {
                    HStack {
                        Image(systemName: "dice.fill")
                        Text("ランダム もんだい")
                    }
                    .primaryButtonStyle()
                }
                .disabled(viewState.isAnswering)

                Button(action: { viewState.showTableSelection() }) {
                    HStack {
                        Image(systemName: "list.number")
                        Text("だんで もんだい")
                    }
                    .primaryButtonStyle()
                }
                .disabled(viewState.isAnswering)
            }
            
            HStack(spacing: Spacing.spacing20) {
                Button(action: { viewState.generateHolePunchQuestion() }) {
                    HStack {
                        Image(systemName: "questionmark.square.fill")
                        Text("むしくい もんだい")
                    }
                    .primaryButtonStyle()
                }
                .disabled(viewState.isAnswering)
            }
            
            HStack(spacing: 20) {
                Button(action: { viewState.toggleChallengeMode() }) {
                    HStack {
                        Image(systemName: viewState.isChallengeModeActive ? "star.fill" : "star")
                        Text(viewState.isChallengeModeActive ? "チャレンジON" : "チャレンジOFF")
                    }
                    .font(.headline)
                    .foregroundColor(viewState.isChallengeModeActive ? .white : .orange)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(viewState.isChallengeModeActive ? Color.orange.opacity(0.8) : Color.white.opacity(0.8))
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.orange, lineWidth: viewState.isChallengeModeActive ? 0 : 2)
                    )
                }
                .disabled(viewState.isAnswering)
                
                // 現在の選択中の段を表示（選択されている場合のみ）
                if let selectedTable = viewState.selectedTable {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("\(selectedTable)の だん")
                        if viewState.isSequentialMode {
                            Text("(\(viewState.currentSequentialNumber-1)/9)")
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(viewState.isSequentialMode ? Color.teal.opacity(0.8) : Color.green.opacity(0.8))
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                    )
                }
            }
        }
    }

    private var soundToggleButton: some View {
        Button(action: {
            soundManager.toggleSound()
        }) {
            HStack {
                Image(systemName: soundManager.isEnabled ? "speaker.wave.3.fill" : "speaker.slash.fill")
                Text(soundManager.isEnabled ? "効果音 ON" : "効果音 OFF")
            }
            .font(.themeSubheadline)
            .foregroundColor(soundManager.isEnabled ? .themePrimary : .themeGray500)
            .padding(.vertical, Spacing.spacing8)
            .padding(.horizontal, Spacing.spacing12)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.8))
                    .shadow(color: Color.black.opacity(ShadowStyle.small.opacity),
                           radius: ShadowStyle.small.radius,
                           x: ShadowStyle.small.x,
                           y: ShadowStyle.small.y)
            )
            .overlay(
                Capsule()
                    .stroke(soundManager.isEnabled ? Color.themePrimary.opacity(0.5) : Color.themeGray300, lineWidth: 1)
            )
        }
    }

    private var difficultQuestionsView: some View {
        let difficultOnes = viewState.getDifficultOnes()

        return Group {
            if (!difficultOnes.isEmpty) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("あなたのにがてな もんだい:")
                        .font(.headline)
                        .foregroundColor(.themePrimary)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(difficultOnes) { diffQuestion in
                                VStack(spacing: 5) {
                                    Text("\(diffQuestion.firstNumber) × \(diffQuestion.secondNumber)")
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(.white)

                                    Text("まちがえた かいすう: \(diffQuestion.incorrectCount)")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                .frame(width: 120, height: 80)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            LinearGradient(
                                                colors: [.red.opacity(0.7), .orange.opacity(0.7)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.7))
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
            }
        }
    }

    // 段選択画面
    private var tableSelectionView: some View {
        NavigationStack {
            ZStack {
                gradientBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("だんを えらんでね")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.themePrimary)
                        .padding()
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(1...9, id: \.self) { table in
                            Button(action: {
                                viewState.selectTable(table)
                            }) {
                                VStack {
                                    Text("\(table)")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("の だん")
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 80)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(buttonColors[(table - 1) % buttonColors.count])
                                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white.opacity(0.6), lineWidth: 2)
                                )
                            }
                        }
                    }
                    .padding()
                }
                .padding()
            }
            .navigationTitle("だんを えらぶ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("とじる") {
                        viewState.showingTableSelection = false
                    }
                }
            }
        }
    }
    
    private var badgeCompactView: some View {
        Button(action: {
            showingBadgeCollection = true
        }) {
            HStack(spacing: Spacing.spacing8) {
                Image(systemName: "medal.fill")
                    .foregroundColor(.themeGold)
                    .font(.system(size: 20))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("バッジ")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.themeGray800)
                    
                    HStack(spacing: 4) {
                        Text("\(badgeSystem.earnedBadgeCount)/\(badgeSystem.totalBadgeCount)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.themePrimary)
                        
                        if !badgeSystem.newBadges.isEmpty {
                            Text("NEW!")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.red)
                                )
                        }
                    }
                }
                
                Spacer()
                
                // 最新の3つのバッジを表示
                HStack(spacing: 4) {
                    ForEach(Array(badgeSystem.earnedBadges.prefix(3)), id: \.badgeType) { badge in
                        if let badgeType = badge.type {
                            Image(systemName: badgeType.displayInfo().icon)
                                .foregroundColor(badgeType.displayInfo().color)
                                .font(.system(size: 16))
                        }
                    }
                }
            }
            .padding(.vertical, Spacing.spacing8)
            .padding(.horizontal, Spacing.spacing12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
