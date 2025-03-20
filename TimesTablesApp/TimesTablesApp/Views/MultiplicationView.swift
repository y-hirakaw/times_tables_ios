import SwiftUI
import SwiftData

struct MultiplicationView: View {
    // ViewStateを利用するように変更
    @StateObject private var viewState: MultiplicationViewState
    
    // SwiftDataの参照
    @Environment(\.modelContext) private var modelContext
    
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
    
    var body: some View {
        NavigationStack {
            VStack {
                if let question = viewState.question {
                    Text(question.question)
                        .font(.title)
                        .padding()
                    
                    // 選択肢ボタンのグリッド
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(viewState.answerChoices, id: \.self) { choice in
                            Button(action: {
                                viewState.checkAnswer(selectedAnswer: choice)
                            }) {
                                Text("\(choice)")
                                    .font(.title2)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(10)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .disabled(viewState.isAnswering) // 回答中はボタンを無効化
                            .opacity(viewState.isAnswering ? 0.6 : 1.0) // 視覚的なフィードバックを追加
                        }
                    }
                    .padding()
                    
                    Text(viewState.resultMessage)
                        .foregroundColor(viewState.resultMessage.contains("正解") ? .green : .red)
                        .font(.headline)
                        .padding()
                    
                    Text("獲得ポイント: \(viewState.getCurrentPoints())")
                } else {
                    Text("ボタンを押して問題を表示しよう！")
                        .font(.title)
                        .padding()
                }
                
                HStack {
                    Button(action: { viewState.generateRandomQuestion() }) {
                        Label("ランダム問題", systemImage: "questionmark.circle")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewState.isAnswering) // 回答中はボタンを無効化
                    
                    Button(action: {
                        viewState.toggleChallengeMode()
                    }) {
                        Label(viewState.isChallengeModeActive ? "チャレンジモード: ON" : "チャレンジモード: OFF", 
                              systemImage: viewState.isChallengeModeActive ? "star.fill" : "star")
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(viewState.isChallengeModeActive ? .orange : .gray)
                    .disabled(viewState.isAnswering) // 回答中はボタンを無効化
                }
                .padding()
                
                // Display difficult questions if any exist
                let difficultOnes = viewState.getDifficultOnes()
                if (!difficultOnes.isEmpty) {
                    Section {
                        Text("あなたの苦手な問題:")
                            .font(.headline)
                            .padding(.top)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(difficultOnes) { diffQuestion in
                                    VStack {
                                        Text("\(diffQuestion.firstNumber) × \(diffQuestion.secondNumber)")
                                            .font(.title3)
                                        Text("Incorrect: \(diffQuestion.incorrectCount)")
                                            .font(.caption)
                                    }
                                    .padding(8)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .padding()
            .navigationTitle("九九ティブ")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // 親用管理画面へのリンク
                    Button {
                        viewState.showParentDashboard()
                    } label: {
                        Label("親用管理画面", systemImage: "person.circle")
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
            // 認証成功時に親用管理画面を表示
            .fullScreenCover(isPresented: $viewState.isAuthenticated) {
                ParentDashboardView()
            }
        }
    }
}
