import SwiftUI

struct Point {
    var value: Int = 0

    mutating func increment() {
        value += 1
    }
}

struct ContentView: View {
    @State private var question: MultiplicationQuestion? = nil
    @State private var answer: String = ""
    @State private var resultMessage: String = ""
    @State private var points = Point()

    var body: some View {
        VStack {
            if let question = question {
                Text(question.question)
                TextField("Answer", text: $answer)
                    .keyboardType(.numberPad)
                Button("Check Answer") {
                    checkAnswer()
                }
                Text(resultMessage)
                    .foregroundColor(resultMessage == "Correct!" ? .green : .red)
                Text("Points: \(points.value)")
            } else {
                Text("Press the button to generate a question")
            }
            Button(action: generateRandomQuestion) {
                Label("Random Question", systemImage: "questionmark.circle")
            }
        }
        .padding()
    }

    private func generateRandomQuestion() {
        question = MultiplicationQuestion.randomQuestion()
        answer = ""
        resultMessage = ""
    }

    private func checkAnswer() {
        guard let question = question else { return }
        if Int(answer) == question.answer {
            resultMessage = "Correct!"
            points.increment()
        } else {
            resultMessage = "Incorrect. Try again."
        }
    }
}

#Preview {
    ContentView()
}
