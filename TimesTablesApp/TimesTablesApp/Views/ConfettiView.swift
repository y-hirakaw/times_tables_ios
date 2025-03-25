import SwiftUI

/// 正解アニメーション用のカスタムビュー
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

/// 正解アニメーションの一部を表すカスタムビュー
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