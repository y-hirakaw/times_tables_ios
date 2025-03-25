import SwiftUI

/// 不正解アニメーション用のカスタムビュー
struct WrongAnswerView: View {
    var body: some View {
        ZStack {
            ForEach(0..<10) { _ in
                WrongAnswerPiece()
            }
        }
    }
}

/// 不正解アニメーションの一部を表すカスタムビュー
struct WrongAnswerPiece: View {
    @State private var xPosition = Double.random(in: -150...150)
    @State private var yPosition = Double.random(in: -150...150)
    @State private var rotation = Double.random(in: 0...360)
    @State private var scale = Double.random(in: 0.5...1.5)

    var body: some View {
        Image(systemName: "xmark.circle.fillxxxxxxxxxxxxx")
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