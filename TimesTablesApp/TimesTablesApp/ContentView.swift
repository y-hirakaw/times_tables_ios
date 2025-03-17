import SwiftUI

struct ContentView: View {
    @State private var question: MultiplicationQuestion? = nil
    @State private var answer: String = ""
    @State private var resultMessage: String = ""

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
        } else {
            resultMessage = "Incorrect. Try again."
        }
    }
}

#Preview {
    ContentView()
}
