import SwiftUI
import PuzzAlarmCore

struct WaterPuzzleView: View {
    let puzzle: WaterPuzzle?
    let onCompleted: () -> Void
    
    @StateObject private var motionManager = MotionManager.shared
    @State private var isPouringActive = false
    @State private var completedPours = 0
    @State private var sourceCupLevel: Double = 1.0
    @State private var targetCupLevel: Double = 0.0
    @State private var targetLevel: Double = 0.5
    @State private var timer: Timer?
    
    private let cupHeight: CGFloat = 200
    private let cupWidth: CGFloat = 80
    
    var body: some View {
        VStack(spacing: 30) {
            // Title and progress
            VStack(spacing: 10) {
                Text("Pour Water to Target Level")
                    .font(.title2)
                    .foregroundColor(.white)
                
                if let puzzle = puzzle {
                    Text("Pour \(completedPours + 1) of \(puzzle.settings.waterCompletionCount)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    // Progress bar
                    ProgressView(value: puzzle.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .cyan))
                        .frame(maxWidth: 200)
                }
                
                Text("Tilt your device to pour water")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            // Target level indicator
            VStack {
                Text("Target Level")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("\(Int(targetLevel * 100))%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.cyan)
            }
            
            // Water cups
            HStack(spacing: 60) {
                // Source cup
                VStack {
                    Text("Source")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    WaterCupView(
                        waterLevel: sourceCupLevel,
                        targetLevel: nil,
                        width: cupWidth,
                        height: cupHeight,
                        isPouring: isPouringActive
                    )
                }
                
                // Target cup
                VStack {
                    Text("Target")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    WaterCupView(
                        waterLevel: targetCupLevel,
                        targetLevel: targetLevel,
                        width: cupWidth,
                        height: cupHeight,
                        isPouring: false
                    )
                }
            }
            
            // Pour status
            VStack {
                if isPouringActive {
                    Text("Pouring...")
                        .font(.caption)
                        .foregroundColor(.cyan)
                } else {
                    Text("Tilt to pour")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Motion status
                HStack {
                    Image(systemName: motionManager.isMotionActive ? "gyroscope" : "gyroscope.badge.xmark")
                        .foregroundColor(motionManager.isMotionActive ? .green : .red)
                    
                    Text(motionManager.isMotionActive ? "Motion Active" : "Motion Unavailable")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            setupWaterPuzzle()
            motionManager.startMotionUpdates()
        }
        .onDisappear {
            motionManager.stopMotionUpdates()
            timer?.invalidate()
        }
        .onChange(of: motionManager.currentTilt) { tilt in
            updatePouring(tilt: tilt)
        }
    }
    
    private func setupWaterPuzzle() {
        guard let puzzle = puzzle else { return }
        
        sourceCupLevel = puzzle.sourceCupWaterLevel
        targetCupLevel = puzzle.targetCupWaterLevel
        targetLevel = puzzle.targetLevel
        completedPours = 0
        
        // Start update timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            updateWaterLevels()
            checkWaterCompletion()
        }
    }
    
    private func updatePouring(tilt: (x: Double, y: Double)) {
        // Check if device is tilted enough to pour (tilt X axis)
        let tiltThreshold = 0.3
        let shouldPour = abs(tilt.x) > tiltThreshold && sourceCupLevel > 0
        
        if shouldPour && !isPouringActive {
            startPouring()
        } else if !shouldPour && isPouringActive {
            stopPouring()
        }
    }
    
    private func startPouring() {
        isPouringActive = true
        puzzle?.startPouring()
    }
    
    private func stopPouring() {
        isPouringActive = false
        puzzle?.stopPouring()
    }
    
    private func updateWaterLevels() {
        guard let puzzle = puzzle else { return }
        
        sourceCupLevel = puzzle.sourceCupWaterLevel
        targetCupLevel = puzzle.targetCupWaterLevel
        
        if isPouringActive && sourceCupLevel > 0 {
            // Simulate pouring animation
            let pourRate = 0.02
            let amountToPour = min(pourRate, sourceCupLevel)
            
            sourceCupLevel -= amountToPour
            targetCupLevel += amountToPour
            
            // Update puzzle state
            puzzle.sourceCupWaterLevel = sourceCupLevel
            puzzle.targetCupWaterLevel = targetCupLevel
        }
    }
    
    private func checkWaterCompletion() {
        if puzzle?.checkCompletion() == true {
            // Puzzle completed
            motionManager.stopMotionUpdates()
            timer?.invalidate()
            onCompleted()
        }
    }
}

struct WaterCupView: View {
    let waterLevel: Double
    let targetLevel: Double?
    let width: CGFloat
    let height: CGFloat
    let isPouring: Bool
    
    var body: some View {
        ZStack {
            // Cup outline
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white, lineWidth: 2)
                .frame(width: width, height: height)
            
            // Target level indicator (if provided)
            if let target = targetLevel {
                Rectangle()
                    .fill(Color.red.opacity(0.3))
                    .frame(width: width - 4, height: 2)
                    .position(x: width/2, y: height - (height * CGFloat(target)))
                
                Text("Target")
                    .font(.caption2)
                    .foregroundColor(.red)
                    .position(x: width + 20, y: height - (height * CGFloat(target)))
            }
            
            // Water
            if waterLevel > 0 {
                VStack {
                    Spacer()
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.cyan, Color.blue],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(
                            width: width - 4,
                            height: max(0, height * CGFloat(waterLevel) - 2)
                        )
                        .cornerRadius(6)
                }
            }
            
            // Pouring effect
            if isPouring {
                Circle()
                    .fill(Color.cyan.opacity(0.7))
                    .frame(width: 6, height: 6)
                    .position(x: width + 10, y: 10)
                    .animation(.easeInOut(duration: 0.5).repeatForever(), value: isPouring)
            }
        }
    }
}

#Preview {
    let puzzle = WaterPuzzle(settings: PuzzleSettings())
    puzzle.start()
    
    return WaterPuzzleView(
        puzzle: puzzle,
        onCompleted: {}
    )
    .background(Color.black)
}