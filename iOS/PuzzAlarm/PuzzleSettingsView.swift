import SwiftUI
import PuzzAlarmCore

struct PuzzleSettingsView: View {
    let puzzleType: PuzzleType
    @Binding var settings: PuzzleSettings
    
    var body: some View {
        Form {
            switch puzzleType {
            case .math:
                Section("Math Puzzle Settings") {
                    Picker("Difficulty", selection: $settings.mathDifficulty) {
                        ForEach(MathDifficulty.allCases, id: \.self) { difficulty in
                            Text(difficulty.displayName).tag(difficulty)
                        }
                    }
                    
                    Stepper("Problems: \(settings.mathProblemCount)", value: $settings.mathProblemCount, in: 1...10)
                    
                    HStack {
                        Text("Time Limit")
                        Spacer()
                        Text("\(Int(settings.mathTimeLimit)) seconds")
                    }
                    Slider(value: Binding(
                        get: { Double(settings.mathTimeLimit) },
                        set: { settings.mathTimeLimit = TimeInterval($0) }
                    ), in: 30...300, step: 30)
                }
                
            case .marbleMaze:
                Section("Marble Maze Settings") {
                    Picker("Difficulty", selection: $settings.mazeDifficulty) {
                        ForEach(MazeDifficulty.allCases, id: \.self) { difficulty in
                            Text(difficulty.displayName).tag(difficulty)
                        }
                    }
                    
                    Stepper("Completions Required: \(settings.mazeCompletionCount)", value: $settings.mazeCompletionCount, in: 1...5)
                }
                
            case .water:
                Section("Water Puzzle Settings") {
                    Stepper("Successful Pours: \(settings.waterCompletionCount)", value: $settings.waterCompletionCount, in: 1...5)
                }
            }
        }
        .navigationTitle("\(puzzleType.displayName) Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        PuzzleSettingsView(
            puzzleType: .math,
            settings: .constant(PuzzleSettings())
        )
    }
}