import SwiftUI
import SwiftData

struct MultiplicationView: View {
    // ViewStateを利用するように変更
    @StateObject private var viewState: MultiplicationViewState
    
    // SwiftDataの参照
    @Environment(\.modelContext) private var modelContext
    
    // アニメーション用の状態変数
    @State private var animateCorrect = false
    @State private var animateWrong = false
    @State private var animateQuestion = false
    @State private var selectedAnswer: Int? = nil
    
    // イニシャライザでViewStateを初期化
    init() {
        // 一時的なモデルコンテキストで初期化
        let schema = Schema([
            DifficultQuestion.self,
            UserPoints.self,
            PointHistory.self,
            PointSpending.self
        ])
        let tempConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let tempContainer = try! ModelContainer(for: schema, configurations: [tempConfig])
        _viewState = StateObject(wrappedValue: MultiplicationViewState(modelContext: ModelContext(tempContainer)))
    }
    
    // カラーテーマ
    private let gradientBackground = LinearGradient(
        colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    private let buttonColors: [Color] = [
        .blue, .green, .orange, .pink, .purple, .red, .yellow, .indigo, .mint
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景グラデーション
                gradientBackground
                    .ignoresSafeArea()
                
                // メインコンテンツ
                ScrollView {
                    VStack(spacing: 20) {
                        // ポイント表示カード
                        pointsCard
                        
                        // もんだい表示エリア
                        if let question = viewState.question {
                            questionView(question)
                        } else {
                            startPrompt
                        }
                        
                        // 回答選択肢エリア
                        if viewState.question != nil {
                            answerChoicesGrid
                        }
                        
                        // 結果メッセージ
                        if !viewState.resultMessage.isEmpty {
                            resultMessageView
                        }
                        
                        // 操作ボタンエリア
                        controlButtons
                        
                        // にがてなもんだいリスト
                        difficultQuestionsView
                    }
                    .padding()
                }
            }
            .navigationTitle("九九ティブ")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // おやよう かんり がめんへのリンク
                    Button {
                        viewState.showParentDashboard()
                    } label: {
                        Label("おやよう かんり がめん", systemImage: "person.circle")
                            .foregroundColor(.indigo)
                    }
                }
            }
            .onAppear {
                // Viewが表示されたら実際のModelContextをViewStateに設定
                viewState.updateModelContext(modelContext)
                
                // アプリ起動時にユーザーポイントが存在しなければ作成
                viewState.ensureUserPointsExists()
            }
            // PIN認証用シート
            .sheet(isPresented: $viewState.showingPINAuth) {
                ParentAccessView(isAuthenticated: $viewState.isAuthenticated)
            }
            // 認証成功時におやよう かんり がめんを表示
            .fullScreenCover(isPresented: $viewState.isAuthenticated) {
                ParentDashboardView()
            }
        }
    }
    
    // ポイント表示カード
    private var pointsCard: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .font(.title)
            
            Text("ポイント: \(viewState.getCurrentPoints())")
                .font(.title3)
                .bold()
                .foregroundColor(.indigo)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.7))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    // もんだい表示ビュー
    private func questionView(_ question: MultiplicationQuestion) -> some View {
        VStack(spacing: 15) {
            Text("もんだい")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 20) {
                Text("\(question.firstNumber)")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.blue)
                    .scaleEffect(animateQuestion ? 1.1 : 1.0)
                
                Text("×")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.indigo)
                
                Text("\(question.secondNumber)")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.purple)
                    .scaleEffect(animateQuestion ? 1.1 : 1.0)
                
                Text("=")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.indigo)
                
                Text("?")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.orange)
                    .scaleEffect(animateQuestion ? 1.3 : 1.0)
            }
            .padding()
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    self.animateQuestion = true
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.9))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    // 開始プロンプト
    private var startPrompt: some View {
        VStack {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 50))
                .foregroundColor(.yellow)
                .padding()
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .shadow(color: .black.opacity(0.1), radius: 5)
                )
            
            Text("ボタンをおして もんだいを見よう！")
                .font(.title2)
                .bold()
                .foregroundColor(.indigo)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.9))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    // 選択肢グリッド
    private var answerChoicesGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
            ForEach(Array(viewState.answerChoices.enumerated()), id: \.element) { index, choice in
                Button(action: {
                    selectedAnswer = choice
                    viewState.checkAnswer(selectedAnswer: choice)
                    
                    if let question = viewState.question, choice == question.answer {
                        animateCorrect = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            animateCorrect = false
                        }
                    } else {
                        animateWrong = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            animateWrong = false
                        }
                    }
                }) {
                    Text("\(choice)")
                        .font(.system(size: 28, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 70)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(
                                    buttonColors[index % buttonColors.count]
                                        .opacity(viewState.isAnswering ? 0.5 : 0.9)
                                )
                                .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 3)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.6), lineWidth: 2)
                        )
                        .scaleEffect(selectedAnswer == choice ? 0.95 : 1.0)
                }
                .buttonStyle(BorderlessButtonStyle())
                .disabled(viewState.isAnswering)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewState.isAnswering)
            }
        }
        .padding(.vertical)
    }
    
    // 結果メッセージビュー
    private var resultMessageView: some View {
        Text(LocalizedStringKey(viewState.resultMessage))
            .font(.title3)
            .bold()
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(viewState.resultMessage.contains("正解") ? .green : .white)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        viewState.resultMessage.contains("正解") 
                        ? Color.green.opacity(0.2) 
                        : Color.red.opacity(0.8)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                viewState.resultMessage.contains("正解") 
                                ? Color.green 
                                : Color.red,
                                lineWidth: viewState.resultMessage.contains("正解") ? 3 : 4
                            )
                    )
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
            .scaleEffect(
                (animateCorrect || animateWrong) ? 1.05 : 1.0
            )
            .animation(.spring(response: 0.3), value: animateCorrect || animateWrong)
            .shadow(
                color: viewState.resultMessage.contains("正解") ? .green.opacity(0.3) : .red.opacity(0.5),
                radius: 5, x: 0, y: 2
            )
    }
    
    // 操作ボタンエリア
    private var controlButtons: some View {
        HStack(spacing: 20) {
            Button(action: { viewState.generateRandomQuestion() }) {
                HStack {
                    Image(systemName: "dice.fill")
                    Text("ランダム もんだい")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.blue.opacity(0.8))
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                )
            }
            .disabled(viewState.isAnswering)
            
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
        }
        .padding(.vertical)
    }
    
    // にがてなもんだい表示ビュー
    private var difficultQuestionsView: some View {
        let difficultOnes = viewState.getDifficultOnes()
        
        return Group {
            if (!difficultOnes.isEmpty) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("あなたのにがてな もんだい:")
                        .font(.headline)
                        .foregroundColor(.indigo)
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
}

// 正解アニメーション用のカスタムビュー
struct ConfettiView: View {
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
    
    var body: some View {
        ZStack {
            ForEach(0..<30) { i in
                ConfettiPiece(color: colors[i % colors.count])
            }
        }
    }
}

struct ConfettiPiece: View {
    @State private var xPosition = Double.random(in: -150...150)
    @State private var yPosition = Double.random(in: -150...150)
    @State private var rotation = Double.random(in: 0...360)
    @State private var scale = Double.random(in: 0.5...1.5)
    
    let color: Color
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 8, height: 8)
            .position(x: xPosition, y: yPosition)
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .opacity(0.7)
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    self.yPosition = Double.random(in: 100...200)
                    self.rotation = Double.random(in: 0...360)
                    self.scale = 0.1
                }
            }
    }
}

// 不正解アニメーション用のカスタムビュー
struct WrongAnswerView: View {
    var body: some View {
        ZStack {
            ForEach(0..<10) { _ in
                WrongAnswerPiece()
            }
        }
    }
}

struct WrongAnswerPiece: View {
    @State private var xPosition = Double.random(in: -150...150)
    @State private var yPosition = Double.random(in: -150...150)
    @State private var rotation = Double.random(in: 0...360)
    @State private var scale = Double.random(in: 0.5...1.5)
    
    var body: some View {
        Image(systemName: "xmark.circle.fill")
            .foregroundColor(.red)
            .font(.system(size: 20))
            .position(x: xPosition, y: yPosition)
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .opacity(0.7)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    self.xPosition += Double.random(in: -50...50)
                    self.yPosition += Double.random(in: -50...50)
                    self.rotation += Double.random(in: -90...90)
                    self.scale = 0.2
                }
            }
    }
}
