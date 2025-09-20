import SwiftUI
import PuzzAlarmCore

struct PuzzleInterface: View {
    let alarm: Alarm
    let onCompleted: () -> Void
    let onDismiss: (TimeInterval) -> Void
    
    @State private var puzzle: (any Puzzle)?
    @State private var startTime = Date()
    @State private var isCompleted = false
    
    var body: some View {
        ZStack {
            // Full screen background
            Color.black.ignoresSafeArea()
            
            VStack {
                // Alarm info header
                VStack(spacing: 8) {
                    Text("ALARM")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(alarm.label)
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text(timeString)
                        .font(.largeTitle)
                        .fontWeight(.thin)
                        .foregroundColor(.white)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Puzzle interface
                Group {
                    if let puzzleType = alarm.puzzleType {
                        switch puzzleType {
                        case .math:
                            MathPuzzleView(
                                puzzle: puzzle as? MathPuzzle,
                                onCompleted: handlePuzzleCompletion
                            )
                        case .marbleMaze:
                            MarbleMazeView(
                                puzzle: puzzle as? MarbleMazePuzzle,
                                onCompleted: handlePuzzleCompletion
                            )
                        case .water:
                            WaterPuzzleView(
                                puzzle: puzzle as? WaterPuzzle,
                                onCompleted: handlePuzzleCompletion
                            )
                        }
                    } else {
                        // No puzzle, just show dismiss button
                        Button("Dismiss Alarm") {
                            handlePuzzleCompletion()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                }
                
                Spacer()
                
                // Snooze button (if enabled)
                if alarm.snoozeEnabled {
                    Button("Snooze") {
                        onCompleted()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.orange)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            startTime = Date()
            initializePuzzle()
        }
        .onDisappear {
            stopPuzzle()
        }
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: alarm.time)
    }
    
    private func initializePuzzle() {
        guard let puzzleType = alarm.puzzleType else { return }
        
        switch puzzleType {
        case .math:
            let mathPuzzle = MathPuzzle(settings: alarm.puzzleSettings)
            mathPuzzle.start()
            puzzle = mathPuzzle
            
        case .marbleMaze:
            let mazePuzzle = MarbleMazePuzzle(settings: alarm.puzzleSettings)
            mazePuzzle.start()
            puzzle = mazePuzzle
            
        case .water:
            let waterPuzzle = WaterPuzzle(settings: alarm.puzzleSettings)
            waterPuzzle.start()
            puzzle = waterPuzzle
        }
    }
    
    private func stopPuzzle() {
        if let puzzle = puzzle {
            puzzle.reset()
        }
    }
    
    private func handlePuzzleCompletion() {
        let completionTime = Date().timeIntervalSince(startTime)
        isCompleted = true
        onDismiss(completionTime)
    }
}

#Preview {
    let alarm = Alarm(
        time: Date(),
        isEnabled: true,
        label: "Wake Up",
        puzzleType: .math,
        puzzleSettings: PuzzleSettings()
    )
    
    PuzzleInterface(
        alarm: alarm,
        onCompleted: {},
        onDismiss: { _ in }
    )
}