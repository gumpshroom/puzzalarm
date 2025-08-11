import Foundation

#if canImport(CoreMotion)
import CoreMotion
#endif

/// Marble maze puzzle that uses device tilt
#if canImport(Combine)
public class MarbleMazePuzzle: Puzzle {
    @Published public var isCompleted: Bool = false
    @Published public var progress: Double = 0.0
    @Published public var timeRemaining: TimeInterval = 300 // 5 minutes default
    @Published public var ballPosition: CGPoint = CGPoint(x: 0.1, y: 0.1)
    @Published public var mazeLayout: [[MazeCellType]] = []
#else
public class MarbleMazePuzzle: Puzzle {
    public var isCompleted: Bool = false
    public var progress: Double = 0.0
    public var timeRemaining: TimeInterval = 300 // 5 minutes default
    public var ballPosition: CGPoint = CGPoint(x: 0.1, y: 0.1)
    public var mazeLayout: [[MazeCellType]] = []
#endif
    
    private let settings: PuzzleSettings
    #if canImport(CoreMotion)
    private let motionManager = CMMotionManager()
    #endif
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
        ballPosition = CGPoint(x: 0.1, y: 0.1)
        generateMaze()
        startMotionUpdates()
        startTimer()
    }
    
    public func reset() {
        timer?.invalidate()
        timer = nil
        #if canImport(CoreMotion)
        motionManager.stopAccelerometerUpdates()
        #endif
        isCompleted = false
        progress = 0.0
        completedMazes = 0
        ballPosition = CGPoint(x: 0.1, y: 0.1)
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
                #if canImport(CoreMotion)
                motionManager.stopAccelerometerUpdates()
                #endif
                return true
            } else {
                // Generate new maze for next round
                ballPosition = CGPoint(x: 0.1, y: 0.1)
                generateMaze()
            }
        }
        
        return false
    }
    
    private func generateMaze() {
        let size = settings.mazeDifficulty.mazeSize
        mazeLayout = MazeGenerator.generate(size: size)
    }
    
    private func startMotionUpdates() {
        #if canImport(CoreMotion)
        guard motionManager.isAccelerometerAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = 1.0 / 60.0 // 60 FPS
        motionManager.startAccelerometerUpdates { [weak self] data, error in
            guard let self = self, let data = data else { return }
            
            DispatchQueue.main.async {
                self.updateBallPosition(acceleration: data.acceleration)
            }
        }
        #endif
    }
    
    #if canImport(CoreMotion)
    private func updateBallPosition(acceleration: CMAcceleration) {
        let sensitivity: Double = 0.02
        let newX = ballPosition.x + acceleration.x * sensitivity
        let newY = ballPosition.y - acceleration.y * sensitivity // Inverted Y
        
        // Clamp to bounds and check for walls
        let clampedX = max(0.0, min(1.0, newX))
        let clampedY = max(0.0, min(1.0, newY))
        
        if isValidPosition(x: clampedX, y: clampedY) {
            ballPosition = CGPoint(x: clampedX, y: clampedY)
            checkCompletion()
        }
    }
    #endif
    
    private func isValidPosition(x: Double, y: Double) -> Bool {
        let row = Int(y * Double(mazeLayout.count))
        let col = Int(x * Double(mazeLayout[0].count))
        
        guard row >= 0 && row < mazeLayout.count && col >= 0 && col < mazeLayout[0].count else {
            return false
        }
        
        return mazeLayout[row][col] != .wall
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
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
        
        // Create a simple maze with guaranteed path
        // Start at top-left
        maze[0][0] = .start
        maze[size-1][size-1] = .end
        
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
            if row != 0 || col != 0 { // Don't override start
                maze[row][col] = .path
            }
        }
        
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