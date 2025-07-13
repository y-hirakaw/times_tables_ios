import SwiftUI
import SwiftData
import AVFoundation

/// メインの九九チャレンジ画面を表示するView
struct MultiplicationView: View {
    @StateObject private var viewState: MultiplicationViewState
    @Environment(\.modelContext) private var modelContext
    @State private var animateCorrect = false
    @State private var animateWrong = false
    @State private var animateQuestion = false
    @State private var selectedAnswer: Int? = nil
    @State private var soundEnabled = true
    @State private var showingPointsHistory = false
    private let correctSoundPlayer: AVAudioPlayer?
    private let wrongSoundPlayer: AVAudioPlayer?

    init() {
        let schema = Schema([
            DifficultQuestion.self,
            UserPoints.self,
            PointHistory.self,
            PointSpending.self,
            AnswerTimeRecord.self
        ])
        let tempConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        let tempContainer = try! ModelContainer(for: schema, configurations: [tempConfig])
        let tempContext = ModelContext(tempContainer)
        
        // モデルコンテキストで必要なデータを事前に作成
        let pointsDescriptor = FetchDescriptor<UserPoints>()
        do {
            let points = try tempContext.fetch(pointsDescriptor)
            if points.isEmpty {
                let newPoints = UserPoints(totalEarnedPoints: 0, availablePoints: 0)
                tempContext.insert(newPoints)
                try tempContext.save()
            }
        } catch {
            print("初期ポイントデータの作成に失敗: \(error)")
        }
        
        _viewState = StateObject(wrappedValue: MultiplicationViewState(modelContext: tempContext))

        // サウンド初期化
        if let correctSoundURL = Bundle.main.url(forResource: "Quiz-Correct_Answer02-2", withExtension: "mp3") {
            correctSoundPlayer = try? AVAudioPlayer(contentsOf: correctSoundURL)
            correctSoundPlayer?.prepareToPlay()
        } else {
            correctSoundPlayer = nil
        }

        if let wrongSoundURL = Bundle.main.url(forResource: "Quiz-Wrong_Buzzer02-3", withExtension: "mp3") {
            wrongSoundPlayer = try? AVAudioPlayer(contentsOf: wrongSoundURL)
            wrongSoundPlayer?.prepareToPlay()
        } else {
            wrongSoundPlayer = nil
        }
    }

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
                    VStack(spacing: Spacing.spacing20) {
                        pointsCard

                        if let question = viewState.question {
                            questionView(question)
                        } else {
                            startPrompt
                        }

                        if !viewState.resultMessage.isEmpty {
                            resultMessageView
                        }

                        if viewState.question != nil && viewState.isTimerRunning {
                            timerView
                        }

                        if viewState.question != nil {
                            answerChoicesGrid
                        }

                        controlButtons
                        soundToggleButton
                        difficultQuestionsView
                    }
                    .padding()
                }
            }
            .navigationTitle("九九ティブ")
            .toolbar {
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
                // メインのModelContextを使ってデータを更新
                viewState.updateModelContext(modelContext)
                // userPointsの存在を確認して初期化
                viewState.ensureUserPointsExists()
                // 最新データを読み込み
                viewState.refreshData()
                
                // 画面が表示されるたびにポイント表示を最新化
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    _ = viewState.getCurrentPoints()
                    viewState.objectWillChange.send()
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
        }
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
            .padding(Spacing.spacing16)
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

    private var timerView: some View {
        VStack(spacing: Spacing.spacing8) {
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(timerColor)

                Text("のこり時間: \(String(format: "%.1f", viewState.remainingTime))秒")
                    .font(.themeSubheadline)
                    .foregroundColor(timerColor)
            }

            ProgressBar(progress: viewState.remainingTime / 10.0)
        }
        .padding(.horizontal, Spacing.spacing16)
        .padding(.bottom, Spacing.spacing8)
    }

    private var timerColor: Color {
        if viewState.remainingTime > 5.0 {
            return .themeSecondary
        } else if viewState.remainingTime > 2.0 {
            return .themeWarning
        } else {
            return .themeError
        }
    }

    private func questionView(_ question: MultiplicationQuestion) -> some View {
        if viewState.isHolePunchMode {
            return AnyView(holePunchQuestionView(question))
        } else {
            return AnyView(standardQuestionView(question))
        }
    }

    private func standardQuestionView(_ question: MultiplicationQuestion) -> some View {
        QuestionCard(question: "\(question.firstNumber) × \(question.secondNumber) = ?", 
                    timeRemaining: Int(viewState.remainingTime))
    }

    private func holePunchQuestionView(_ question: MultiplicationQuestion) -> some View {
        QuestionCard(question: "\(question.firstNumber) × □ = \(question.firstNumber * question.secondNumber)", 
                    timeRemaining: Int(viewState.remainingTime))
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

    private var answerChoicesGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.spacing16) {
            ForEach(Array(viewState.answerChoices.enumerated()), id: \.element) { index, choice in
                Button(action: {
                    selectedAnswer = choice
                    viewState.checkAnswer(selectedAnswer: choice)

                    if let question = viewState.question, choice == question.answer {
                        if soundEnabled {
                            correctSoundPlayer?.play()
                        }

                        animateCorrect = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            animateCorrect = false
                        }
                    } else {
                        if soundEnabled {
                            wrongSoundPlayer?.play()
                        }

                        animateWrong = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            animateWrong = false
                        }
                    }
                }) {
                    Text("\(choice)")
                        .answerButtonStyle(isSelected: selectedAnswer == choice)
                }
                .buttonStyle(BorderlessButtonStyle())
                .disabled(viewState.isAnswering)
            }
        }
        .padding(.vertical, Spacing.spacing16)
    }

    private var resultMessageView: some View {
        let isError = viewState.resultMessage.contains("不正解") || viewState.resultMessage.contains("時間切れ")
        
        return Text(LocalizedStringKey(viewState.resultMessage))
            .font(.themeTitle3)
            .foregroundColor(.white)
            .padding(Spacing.spacing16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.large)
                    .fill(isError ? Color.themeError : Color.themeSecondary)
            )
            .overlay(
                Group {
                    if animateCorrect {
                        ConfettiView()
                    } else if animateWrong {
                        WrongAnswerView()
                    }
                }
            )
            .scaleEffect((animateCorrect || animateWrong) ? 1.05 : 1.0)
            .animation(AnimationStyle.springBouncy, value: animateCorrect || animateWrong)
            .shadow(color: Color.black.opacity(ShadowStyle.medium.opacity),
                   radius: ShadowStyle.medium.radius,
                   x: ShadowStyle.medium.x,
                   y: ShadowStyle.medium.y)
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
            
            // 停止ボタン - 問題が表示されているときのみ表示
            if viewState.question != nil {
                Button(action: { viewState.cancelQuestion() }) {
                    HStack {
                        Image(systemName: "stop.circle.fill")
                        Text("もんだいを やめる")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.red.opacity(0.8))
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                    )
                }
                .disabled(viewState.isAnswering)
            }
        }
    }

    private var soundToggleButton: some View {
        Button(action: {
            soundEnabled.toggle()
            if soundEnabled {
                correctSoundPlayer?.play()
            }
        }) {
            HStack {
                Image(systemName: soundEnabled ? "speaker.wave.3.fill" : "speaker.slash.fill")
                Text(soundEnabled ? "効果音 ON" : "効果音 OFF")
            }
            .font(.headline)
            .foregroundColor(soundEnabled ? .blue : .gray)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.8))
                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
            )
            .overlay(
                Capsule()
                    .stroke(soundEnabled ? Color.blue.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
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
}
