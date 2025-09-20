import SwiftUI
import PuzzAlarmCore

struct MathPuzzleView: View {
    let puzzle: MathPuzzle?
    let onCompleted: () -> Void
    
    @State private var userAnswer = ""
    @State private var currentProblemIndex = 0
    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: Timer?
    @State private var isAnswerIncorrect = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Title and progress
            VStack(spacing: 10) {
                Text("Solve Math Problems")
                    .font(.title2)
                    .foregroundColor(.white)
                
                if let puzzle = puzzle {
                    Text("Problem \(currentProblemIndex + 1) of \(puzzle.problems.count)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    // Progress bar
                    ProgressView(value: puzzle.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .frame(maxWidth: 200)
                }
            }
            
            // Timer
            VStack {
                Text("Time Remaining")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(timeString(timeRemaining))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(timeRemaining < 30 ? .red : .white)
            }
            
            // Current problem
            if let puzzle = puzzle, currentProblemIndex < puzzle.problems.count {
                let currentProblem = puzzle.problems[currentProblemIndex]
                
                VStack(spacing: 20) {
                    Text(currentProblem.questionText)
                        .font(.largeTitle)
                        .fontWeight(.thin)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    // Answer input
                    TextField("Your answer", text: $userAnswer)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 200)
                        .background(isAnswerIncorrect ? Color.red.opacity(0.3) : Color.clear)
                        .cornerRadius(8)
                    
                    // Submit button
                    Button("Submit") {
                        checkAnswer(currentProblem.answer)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(userAnswer.isEmpty)
                }
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            setupPuzzle()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .onChange(of: userAnswer) { _ in
            isAnswerIncorrect = false
        }
    }
    
    private func setupPuzzle() {
        guard let puzzle = puzzle else { return }
        
        timeRemaining = puzzle.timeRemaining
        currentProblemIndex = 0
        
        // Start countdown timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                // Time's up - alarm continues
            }
        }
    }
    
    private func checkAnswer(_ correctAnswer: Int) {
        guard let answer = Int(userAnswer) else {
            isAnswerIncorrect = true
            return
        }
        
        if answer == correctAnswer {
            // Correct answer
            currentProblemIndex += 1
            userAnswer = ""
            
            // Check if puzzle is completed
            if currentProblemIndex >= puzzle?.problems.count ?? 0 {
                timer?.invalidate()
                onCompleted()
            }
        } else {
            // Incorrect answer
            isAnswerIncorrect = true
            userAnswer = ""
        }
    }
    
    private func timeString(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    let puzzle = MathPuzzle(settings: PuzzleSettings())
    puzzle.start()
    
    return MathPuzzleView(
        puzzle: puzzle,
        onCompleted: {}
    )
    .background(Color.black)
}