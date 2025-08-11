import Foundation

/// Water pouring puzzle that simulates device tilt for water pouring
public class WaterPuzzle: Puzzle {
    public var isCompleted: Bool = false
    public var progress: Double = 0.0
    public var timeRemaining: TimeInterval = 300 // 5 minutes default
    public var sourceCupWaterLevel: Double = 1.0 // Start full
    public var targetCupWaterLevel: Double = 0.0 // Start empty
    public var targetLevel: Double = 0.0 // Random target level
    public var isPouringActive: Bool = false
    
    private let settings: PuzzleSettings
    private var completedPours: Int = 0
    private var timer: Timer?
    private var pourTimer: Timer?
    
    public init(settings: PuzzleSettings) {
        self.settings = settings
        generateNewTarget()
    }
    
    public func start() {
        isCompleted = false
        completedPours = 0
        progress = 0.0
        timeRemaining = 300
        sourceCupWaterLevel = 1.0
        targetCupWaterLevel = 0.0
        generateNewTarget()
        startTimer()
    }
    
    public func reset() {
        timer?.invalidate()
        timer = nil
        pourTimer?.invalidate()
        pourTimer = nil
        isCompleted = false
        progress = 0.0
        completedPours = 0
        sourceCupWaterLevel = 1.0
        targetCupWaterLevel = 0.0
        generateNewTarget()
    }
    
    public func checkCompletion() -> Bool {
        // Check if target level is achieved (within tolerance)
        let tolerance = 0.05
        if abs(targetCupWaterLevel - targetLevel) <= tolerance {
            completedPours += 1
            progress = Double(completedPours) / Double(settings.waterCompletionCount)
            
            if completedPours >= settings.waterCompletionCount {
                isCompleted = true
                timer?.invalidate()
                pourTimer?.invalidate()
                return true
            } else {
                // Generate new target for next round
                sourceCupWaterLevel = 1.0
                targetCupWaterLevel = 0.0
                generateNewTarget()
            }
        }
        
        return false
    }
    
    // Manual pouring control for testing (simulates device tilt)
    public func startPouring() {
        guard !isPouringActive && sourceCupWaterLevel > 0 else { return }
        
        isPouringActive = true
        
        // Start pouring animation/logic
        pourTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.pouringUpdate()
        }
    }
    
    public func stopPouring() {
        isPouringActive = false
        pourTimer?.invalidate()
        pourTimer = nil
        
        // Check if we've achieved the target
        _ = checkCompletion()
    }
    
    private func generateNewTarget() {
        // Generate random target level between 0.2 and 0.8
        targetLevel = Double.random(in: 0.2...0.8)
    }
    
    private func pouringUpdate() {
        let pourRate = 0.02 // How fast water pours
        
        if sourceCupWaterLevel > 0 && targetCupWaterLevel < 1.0 {
            let pourAmount = min(pourRate, sourceCupWaterLevel, 1.0 - targetCupWaterLevel)
            sourceCupWaterLevel -= pourAmount
            targetCupWaterLevel += pourAmount
        } else {
            stopPouring()
        }
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

/// Water cup representation
public struct WaterCup {
    public var waterLevel: Double // 0.0 to 1.0
    public var capacity: Double = 1.0
    public let position: SimplePoint
    
    public init(waterLevel: Double = 0.0, position: SimplePoint = .zero) {
        self.waterLevel = max(0.0, min(1.0, waterLevel))
        self.position = position
    }
    
    public mutating func addWater(_ amount: Double) -> Double {
        let previousLevel = waterLevel
        waterLevel = min(capacity, waterLevel + amount)
        return waterLevel - previousLevel // Actual amount added
    }
    
    public mutating func removeWater(_ amount: Double) -> Double {
        let previousLevel = waterLevel
        waterLevel = max(0.0, waterLevel - amount)
        return previousLevel - waterLevel // Actual amount removed
    }
    
    public var isEmpty: Bool {
        return waterLevel <= 0.0
    }
    
    public var isFull: Bool {
        return waterLevel >= capacity
    }
}