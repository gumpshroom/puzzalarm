import SwiftUI
import PuzzAlarmCore

struct MarbleMazeView: View {
    let puzzle: MarbleMazePuzzle?
    let onCompleted: () -> Void
    
    @StateObject private var motionManager = MotionManager.shared
    @State private var ballPosition: CGPoint = CGPoint(x: 50, y: 50)
    @State private var mazeSize: CGSize = CGSize(width: 300, height: 300)
    @State private var completedMazes = 0
    @State private var timer: Timer?
    
    private let ballSize: CGFloat = 20
    private let wallThickness: CGFloat = 4
    
    var body: some View {
        VStack(spacing: 30) {
            // Title and progress
            VStack(spacing: 10) {
                Text("Navigate the Maze")
                    .font(.title2)
                    .foregroundColor(.white)
                
                if let puzzle = puzzle {
                    Text("Maze \(completedMazes + 1) of \(puzzle.settings.mazeCompletionCount)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    // Progress bar
                    ProgressView(value: puzzle.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .green))
                        .frame(maxWidth: 200)
                }
                
                Text("Tilt your device to move the ball")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            // Maze view
            ZStack {
                // Maze background
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: mazeSize.width, height: mazeSize.height)
                    .cornerRadius(8)
                
                // Maze walls
                if let puzzle = puzzle {
                    MazeWallsView(maze: puzzle.mazeLayout, size: mazeSize)
                }
                
                // Start indicator
                Circle()
                    .fill(Color.green)
                    .frame(width: 10, height: 10)
                    .position(x: 25, y: 25)
                
                // End indicator
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
                    .position(x: mazeSize.width - 25, y: mazeSize.height - 25)
                
                // Ball
                Circle()
                    .fill(Color.blue)
                    .frame(width: ballSize, height: ballSize)
                    .position(ballPosition)
                    .shadow(radius: 3)
            }
            
            // Motion status
            HStack {
                Image(systemName: motionManager.isMotionActive ? "gyroscope" : "gyroscope.badge.xmark")
                    .foregroundColor(motionManager.isMotionActive ? .green : .red)
                
                Text(motionManager.isMotionActive ? "Motion Active" : "Motion Unavailable")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            setupMaze()
            motionManager.startMotionUpdates()
        }
        .onDisappear {
            motionManager.stopMotionUpdates()
            timer?.invalidate()
        }
        .onChange(of: motionManager.currentTilt) { tilt in
            updateBallPosition(tilt: tilt)
        }
    }
    
    private func setupMaze() {
        guard let puzzle = puzzle else { return }
        
        ballPosition = CGPoint(x: 25, y: 25) // Start position
        completedMazes = 0
        
        // Start update timer for physics simulation
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            // 60 FPS updates
            checkMazeCompletion()
        }
    }
    
    private func updateBallPosition(tilt: (x: Double, y: Double)) {
        let sensitivity: CGFloat = 3.0
        let newX = ballPosition.x + CGFloat(tilt.x) * sensitivity
        let newY = ballPosition.y - CGFloat(tilt.y) * sensitivity // Invert Y for natural feel
        
        // Clamp to maze bounds
        let clampedX = max(ballSize/2, min(mazeSize.width - ballSize/2, newX))
        let clampedY = max(ballSize/2, min(mazeSize.height - ballSize/2, newY))
        
        ballPosition = CGPoint(x: clampedX, y: clampedY)
        
        // Update puzzle with normalized position
        let normalizedX = Double(clampedX / mazeSize.width)
        let normalizedY = Double(clampedY / mazeSize.height)
        puzzle?.ballPosition = SimplePoint(x: normalizedX, y: normalizedY)
    }
    
    private func checkMazeCompletion() {
        // Check if ball reached the end (within tolerance)
        let endPosition = CGPoint(x: mazeSize.width - 25, y: mazeSize.height - 25)
        let distance = sqrt(pow(ballPosition.x - endPosition.x, 2) + pow(ballPosition.y - endPosition.y, 2))
        
        if distance < 20 { // Close enough to end
            if puzzle?.checkCompletion() == true {
                // Puzzle completed
                motionManager.stopMotionUpdates()
                timer?.invalidate()
                onCompleted()
            } else {
                // Move to next maze
                completedMazes += 1
                ballPosition = CGPoint(x: 25, y: 25) // Reset to start
            }
        }
    }
}

struct MazeWallsView: View {
    let maze: [[MazeCellType]]
    let size: CGSize
    
    var body: some View {
        // Simplified maze walls representation
        // In a real implementation, this would draw actual walls based on the maze layout
        ForEach(0..<maze.count, id: \.self) { row in
            ForEach(0..<maze[row].count, id: \.self) { col in
                if maze[row][col] == .wall {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: size.width / CGFloat(maze[row].count), 
                               height: size.height / CGFloat(maze.count))
                        .position(
                            x: CGFloat(col) * size.width / CGFloat(maze[row].count) + size.width / CGFloat(maze[row].count) / 2,
                            y: CGFloat(row) * size.height / CGFloat(maze.count) + size.height / CGFloat(maze.count) / 2
                        )
                }
            }
        }
    }
}

#Preview {
    let puzzle = MarbleMazePuzzle(settings: PuzzleSettings())
    puzzle.start()
    
    return MarbleMazeView(
        puzzle: puzzle,
        onCompleted: {}
    )
    .background(Color.black)
}