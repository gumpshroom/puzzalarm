import Foundation

/// Simple point structure for basic 2D coordinates
public struct SimplePoint: Codable {
    public var x: Double
    public var y: Double
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    public static let zero = SimplePoint(x: 0, y: 0)
}

/// Marble maze puzzle that uses device tilt (simulated for testing)
public class MarbleMazePuzzle: Puzzle {
    public var isCompleted: Bool = false
    public var progress: Double = 0.0
    public var timeRemaining: TimeInterval = 300 // 5 minutes default
    public var ballPosition: SimplePoint = SimplePoint(x: 0.1, y: 0.1)
    public var mazeLayout: [[MazeCellType]] = []
    
    private let settings: PuzzleSettings
    private var completedMazes: Int = 0
    private var timer: Timer?
    
    public init(settings: PuzzleSettings) {
        self.settings = settings
        generateMaze()
    }
    
    public func start() {
        isCompleted = false
        completedMazes = 0
        progress = 0.0
        timeRemaining = 300
        ballPosition = SimplePoint(x: 0.1, y: 0.1)
        generateMaze()
        startTimer()
    }
    
    public func reset() {
        timer?.invalidate()
        timer = nil
        isCompleted = false
        progress = 0.0
        completedMazes = 0
        ballPosition = SimplePoint(x: 0.1, y: 0.1)
        generateMaze()
    }
    
    public func checkCompletion() -> Bool {
        // Check if ball reached the end
        let endRow = mazeLayout.count - 1
        let endCol = mazeLayout[0].count - 1
        let ballRow = Int(ballPosition.y * Double(mazeLayout.count))
        let ballCol = Int(ballPosition.x * Double(mazeLayout[0].count))
        
        if ballRow == endRow && ballCol == endCol {
            completedMazes += 1
            progress = Double(completedMazes) / Double(settings.mazeCompletionCount)
            
            if completedMazes >= settings.mazeCompletionCount {
                isCompleted = true
                timer?.invalidate()
                return true
            } else {
                // Generate new maze for next round
                ballPosition = SimplePoint(x: 0.1, y: 0.1)
                generateMaze()
            }
        }
        
        return false
    }
    
    // Simulate device tilt with manual ball movement for testing
    public func moveBall(deltaX: Double, deltaY: Double) {
        let newX = ballPosition.x + deltaX
        let newY = ballPosition.y + deltaY
        
        // Clamp to bounds and check for walls
        let clampedX = max(0.0, min(1.0, newX))
        let clampedY = max(0.0, min(1.0, newY))
        
        if isValidPosition(x: clampedX, y: clampedY) {
            ballPosition = SimplePoint(x: clampedX, y: clampedY)
            _ = checkCompletion()
        }
    }
    
    private func generateMaze() {
        let size = settings.mazeDifficulty.mazeSize
        mazeLayout = MazeGenerator.generate(size: size)
    }
    
    private func isValidPosition(x: Double, y: Double) -> Bool {
        let row = Int(y * Double(mazeLayout.count))
        let col = Int(x * Double(mazeLayout[0].count))
        
        guard row >= 0 && row < mazeLayout.count && col >= 0 && col < mazeLayout[0].count else {
            return false
        }
        
        return mazeLayout[row][col] != .wall
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

/// Types of maze cells
public enum MazeCellType: Int, CaseIterable {
    case path = 0
    case wall = 1
    case start = 2
    case end = 3
}

/// Maze generation utility
public struct MazeGenerator {
    public static func generate(size: Int) -> [[MazeCellType]] {
        var maze = Array(repeating: Array(repeating: MazeCellType.wall, count: size), count: size)
        
        // Create a guaranteed path
        var currentRow = 0
        var currentCol = 0
        
        while currentRow < size - 1 || currentCol < size - 1 {
            maze[currentRow][currentCol] = .path
            
            // Randomly choose to go right or down (if possible)
            if currentRow == size - 1 {
                currentCol += 1
            } else if currentCol == size - 1 {
                currentRow += 1
            } else {
                if Bool.random() {
                    currentCol += 1
                } else {
                    currentRow += 1
                }
            }
        }
        
        // Add some additional paths for complexity
        for _ in 0..<(size * size / 4) {
            let row = Int.random(in: 0..<size)
            let col = Int.random(in: 0..<size)
            if (row != 0 || col != 0) && (row != size-1 || col != size-1) { // Don't override start or end
                maze[row][col] = .path
            }
        }
        
        // Set start and end positions (after path creation to ensure they're not overwritten)
        maze[0][0] = .start
        maze[size-1][size-1] = .end
        
        return maze
    }
}

/// Maze difficulty settings
extension MazeDifficulty {
    var mazeSize: Int {
        switch self {
        case .easy: return 8
        case .medium: return 12
        case .hard: return 16
        case .expert: return 20
        }
    }
}