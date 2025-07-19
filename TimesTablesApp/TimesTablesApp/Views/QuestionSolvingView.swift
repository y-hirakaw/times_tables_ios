import SwiftUI

/// 問題を解くための専用画面
struct QuestionSolvingView: View {
    @ObservedObject var viewState: MultiplicationViewState
    @Environment(\.soundManager) private var soundManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedAnswer: Int? = nil
    @State private var animateCorrect = false
    @State private var animateWrong = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景グラデーション
                LinearGradient(
                    colors: [Color.themePrimary.opacity(0.1), Color.themePrimaryLight.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 上部エリア（10%）- 中止ボタン
                    HStack {
                        Spacer()
                        cancelButton
                    }
                    .frame(height: geometry.size.height * 0.1)
                    .padding(.horizontal, Spacing.spacing16)
                    
                    // 問題表示エリア（20%）
                    if let question = viewState.question {
                        questionView(question: question, availableHeight: geometry.size.height * 0.2)
                    }
                    
                    // タイマーエリア（10%）
                    if viewState.isTimerRunning {
                        timerView
                            .frame(height: geometry.size.height * 0.1)
                    } else {
                        Spacer()
                            .frame(height: geometry.size.height * 0.1)
                    }
                    
                    // 結果メッセージエリア（15%）
                    if !viewState.resultMessage.isEmpty {
                        resultMessageView
                            .frame(minHeight: geometry.size.height * 0.15)
                            .padding(.horizontal, Spacing.spacing16)
                    } else {
                        Spacer()
                            .frame(height: geometry.size.height * 0.15)
                    }
                    
                    // 回答選択肢エリア（35%）
                    if viewState.question != nil {
                        answerChoicesGrid(availableHeight: geometry.size.height * 0.35)
                    }
                    
                    // 下部エリア（10%）
                    Spacer()
                        .frame(height: geometry.size.height * 0.1)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            selectedAnswer = nil
        }
        .onChange(of: viewState.question?.identifier) { _, _ in
            selectedAnswer = nil
        }
        .onChange(of: viewState.question) { _, newQuestion in
            // 問題がnilになった場合（順番モード終了など）は自動的に元の画面に戻る
            if newQuestion == nil {
                // 少し待ってから戻る（結果メッセージを表示するため）
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    dismiss()
                }
            }
        }
    }
    
    // MARK: - 問題表示
    private func questionView(question: MultiplicationQuestion, availableHeight: CGFloat) -> some View {
        VStack(spacing: Spacing.spacing8) {
            // 苦手問題の場合はインジケーターを表示
            if viewState.isDifficultQuestion(question) {
                HStack(spacing: Spacing.spacing4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.themeWarning)
                        .font(.system(size: min(availableHeight * 0.12, 18)))
                    Text("にがてもんだい！")
                        .font(.system(size: min(availableHeight * 0.12, 18), weight: .bold))
                        .foregroundColor(.themeWarning)
                    Text("+2 EXP")
                        .font(.system(size: min(availableHeight * 0.1, 16), weight: .bold))
                        .foregroundColor(.themeWarning)
                        .padding(.horizontal, Spacing.spacing8)
                        .padding(.vertical, Spacing.spacing4)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.small)
                                .fill(Color.themeWarning.opacity(0.2))
                        )
                }
                .padding(.bottom, Spacing.spacing4)
            }
            
            Text(NSLocalizedString("もんだい", comment: "Problem"))
                .font(.system(size: min(availableHeight * 0.15, 20), weight: .semibold))
                .foregroundColor(.themeGray600)
            
            if viewState.isHolePunchMode {
                Text("\(question.firstNumber) × □ = \(question.firstNumber * question.secondNumber)")
                    .font(.system(size: min(availableHeight * 0.35, 36), weight: .bold))
                    .foregroundColor(.themeGray800)
                    .multilineTextAlignment(.center)
            } else {
                Text("\(question.firstNumber) × \(question.secondNumber) = ?")
                    .font(.system(size: min(availableHeight * 0.35, 36), weight: .bold))
                    .foregroundColor(.themeGray800)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(height: availableHeight)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(ShadowStyle.medium.opacity),
                       radius: ShadowStyle.medium.radius,
                       x: ShadowStyle.medium.x,
                       y: ShadowStyle.medium.y)
        )
        .overlay(
            // 苦手問題の場合は枠線を追加
            viewState.isDifficultQuestion(question) ?
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .stroke(Color.themeWarning, lineWidth: 3)
            : nil
        )
        .padding(.horizontal, Spacing.spacing16)
    }
    
    // MARK: - タイマー表示
    private var timerView: some View {
        VStack(spacing: Spacing.spacing8) {
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(timerColor)
                Text(String(format: NSLocalizedString("のこり時間: %@秒", comment: "Remaining time: %@ seconds"), String(format: "%.1f", viewState.remainingTime)))
                    .font(.themeTitle3)
                    .foregroundColor(timerColor)
            }
            
            ProgressBar(progress: viewState.remainingTime / GameConstants.Timer.questionTimeLimit)
                .frame(height: 12)
        }
        .padding(.horizontal, Spacing.spacing16)
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
    
    // MARK: - 結果メッセージ
    private var resultMessageView: some View {
        let isError = viewState.resultMessage.contains("不正解") || viewState.resultMessage.contains("時間切れ") || viewState.resultMessage.contains("まちがい") || viewState.resultMessage.contains("じかん きれ")
        
        return Text(LocalizedStringKey(viewState.resultMessage))
            .font(.themeTitle3)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
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
    
    // MARK: - 回答選択肢
    private func answerChoicesGrid(availableHeight: CGFloat) -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: Spacing.spacing16),
            GridItem(.flexible(), spacing: Spacing.spacing16),
            GridItem(.flexible(), spacing: Spacing.spacing16)
        ], spacing: Spacing.spacing16) {
            ForEach(Array(viewState.answerChoices.enumerated()), id: \.element) { index, choice in
                Button(action: {
                    selectedAnswer = choice
                    viewState.checkAnswer(selectedAnswer: choice)
                    
                    // 正解判定
                    let isCorrect: Bool
                    if let question = viewState.question {
                        if viewState.isHolePunchMode {
                            isCorrect = choice == question.secondNumber
                        } else {
                            isCorrect = choice == question.answer
                        }
                    } else {
                        isCorrect = false
                    }
                    
                    // サウンド再生とアニメーション
                    if isCorrect {
                        soundManager.play(.correct)
                        animateCorrect = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.Animation.feedbackAnimationDuration) {
                            animateCorrect = false
                        }
                        
                        // 正解時は少し待ってから次の問題への準備
                        DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.Animation.correctAnswerDisplayDuration) {
                            selectedAnswer = nil
                        }
                    } else {
                        soundManager.play(.wrong)
                        animateWrong = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.Animation.feedbackAnimationDuration) {
                            animateWrong = false
                        }
                        
                        // 不正解時も少し待ってから次の問題への準備
                        DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.Animation.incorrectAnswerDisplayDuration) {
                            selectedAnswer = nil
                        }
                    }
                }) {
                    Text("\(choice)")
                        .font(.system(size: min(availableHeight * 0.15, 32), weight: .bold))
                        .foregroundColor(buttonForegroundColor(for: choice))
                        .frame(maxWidth: .infinity)
                        .frame(height: min(availableHeight * 0.25, 100))
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.large)
                                .fill(buttonBackgroundColor(for: choice))
                        )
                        .shadow(color: Color.black.opacity(ShadowStyle.medium.opacity),
                               radius: ShadowStyle.medium.radius,
                               x: ShadowStyle.medium.x,
                               y: ShadowStyle.medium.y)
                        .scaleEffect(selectedAnswer == choice ? 0.95 : 1.0)
                        .animation(AnimationStyle.springBouncy, value: selectedAnswer == choice)
                }
                .buttonStyle(BorderlessButtonStyle())
                .disabled(viewState.isAnswering)
            }
        }
        .padding(.horizontal, Spacing.spacing16)
    }
    
    private func buttonForegroundColor(for choice: Int) -> Color {
        if selectedAnswer == choice {
            return .white
        } else {
            return .themeGray800
        }
    }
    
    private func buttonBackgroundColor(for choice: Int) -> Color {
        if selectedAnswer == choice {
            return .themePrimary
        } else {
            return .white
        }
    }
    
    // MARK: - 中止ボタン
    private var cancelButton: some View {
        Button(action: {
            viewState.cancelQuestion()
            selectedAnswer = nil
            dismiss()
        }) {
            HStack {
                Image(systemName: "xmark.circle.fill")
                Text(NSLocalizedString("やめる", comment: "Quit"))
            }
            .font(.themeTitle3)
            .foregroundColor(.white)
            .padding(.horizontal, Spacing.spacing32)
            .padding(.vertical, Spacing.spacing16)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.large)
                    .fill(Color.themeError)
            )
            .shadow(color: Color.black.opacity(ShadowStyle.medium.opacity),
                   radius: ShadowStyle.medium.radius,
                   x: ShadowStyle.medium.x,
                   y: ShadowStyle.medium.y)
        }
    }
}