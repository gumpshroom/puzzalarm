import Foundation

/// Protocol for all puzzles
public protocol Puzzle: AnyObject {
    var isCompleted: Bool { get }
    var progress: Double { get }
    var timeRemaining: TimeInterval { get }
    
    func start()
    func reset()
    func checkCompletion() -> Bool
}

/// Math puzzle implementation
public class MathPuzzle: Puzzle {
    public var isCompleted: Bool = false
    public var progress: Double = 0.0
    public var timeRemaining: TimeInterval = 0
    public var currentProblem: MathProblem?
    public var correctAnswers: Int = 0
    
    private let settings: PuzzleSettings
    private let totalProblems: Int
    private var startTime: Date?
    private var timer: Timer?
    
    public init(settings: PuzzleSettings) {
        self.settings = settings
        self.totalProblems = settings.mathProblemCount
        self.timeRemaining = settings.mathTimeLimit
    }
    
    public func start() {
        startTime = Date()
        correctAnswers = 0
        isCompleted = false
        generateNewProblem()
        startTimer()
    }
    
    public func reset() {
        timer?.invalidate()
        timer = nil
        isCompleted = false
        progress = 0.0
        correctAnswers = 0
        currentProblem = nil
        timeRemaining = settings.mathTimeLimit
    }
    
    public func checkCompletion() -> Bool {
        let completed = correctAnswers >= totalProblems
        if completed {
            isCompleted = true
            timer?.invalidate()
        }
        return completed
    }
    
    public func submitAnswer(_ answer: Int) -> Bool {
        guard let problem = currentProblem else { return false }
        
        let isCorrect = answer == problem.correctAnswer
        if isCorrect {
            correctAnswers += 1
            progress = Double(correctAnswers) / Double(totalProblems)
            
            if !checkCompletion() {
                generateNewProblem()
            }
        } else {
            // Wrong answer - generate new problem
            generateNewProblem()
        }
        
        return isCorrect
    }
    
    private func generateNewProblem() {
        currentProblem = MathProblem.generate(difficulty: settings.mathDifficulty)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.timeRemaining -= 1
            if self.timeRemaining <= 0 {
                self.timer?.invalidate()
                // Time's up - puzzle failed
            }
        }
    }
}

/// Math problem structure
public struct MathProblem {
    public let operand1: Int
    public let operand2: Int
    public let operation: MathOperation
    public let correctAnswer: Int
    
    public var questionText: String {
        let operatorSymbol = operation.symbol
        return "\(operand1) \(operatorSymbol) \(operand2) = ?"
    }
    
    public static func generate(difficulty: MathDifficulty) -> MathProblem {
        let (range, operations) = difficulty.parameters
        let operand1 = Int.random(in: range)
        let operand2 = Int.random(in: range)
        let operation = operations.randomElement()!
        
        let answer: Int
        switch operation {
        case .addition:
            answer = operand1 + operand2
        case .subtraction:
            answer = operand1 - operand2
        case .multiplication:
            answer = operand1 * operand2
        case .division:
            // Ensure clean division
            let dividend = operand1 * operand2
            return MathProblem(operand1: dividend, operand2: operand1, operation: operation, correctAnswer: operand2)
        }
        
        return MathProblem(operand1: operand1, operand2: operand2, operation: operation, correctAnswer: answer)
    }
}

/// Math operations
public enum MathOperation: CaseIterable {
    case addition, subtraction, multiplication, division
    
    public var symbol: String {
        switch self {
        case .addition: return "+"
        case .subtraction: return "-"
        case .multiplication: return "×"
        case .division: return "÷"
        }
    }
}

/// Difficulty parameters for math puzzles
extension MathDifficulty {
    var parameters: (range: ClosedRange<Int>, operations: [MathOperation]) {
        switch self {
        case .easy:
            return (1...10, [.addition, .subtraction])
        case .medium:
            return (1...25, [.addition, .subtraction, .multiplication])
        case .hard:
            return (1...50, MathOperation.allCases)
        case .expert:
            return (1...100, MathOperation.allCases)
        }
    }
}