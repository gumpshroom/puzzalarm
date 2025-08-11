import Foundation

/// Simple sleep detection service (stub for platforms without HealthKit)
public class SleepDetectionService {
    public var isMonitoring: Bool = false
    public var currentHeartRate: Double = 0
    public var currentMovement: Double = 0
    public var sleepState: SleepState = .awake
    
    // Simulated thresholds for sleep detection
    private let sleepHeartRateThreshold: Double = 60 // BPM below which suggests sleep
    private let awakeHeartRateThreshold: Double = 80 // BPM above which suggests awake
    private let movementThreshold: Double = 0.1 // Movement threshold for sleep detection
    private let sleepDetectionDuration: TimeInterval = 300 // 5 minutes of consistent data
    
    private var heartRateHistory: [(Date, Double)] = []
    private var movementHistory: [(Date, Double)] = []
    private var monitoringStartTime: Date?
    private var simulationTimer: Timer?
    
    public init() {}
    
    // MARK: - Public Methods
    
    public func startMonitoring() {
        isMonitoring = true
        monitoringStartTime = Date()
        sleepState = .awake
        
        // Start simulation for testing
        startSimulation()
    }
    
    public func stopMonitoring() {
        isMonitoring = false
        monitoringStartTime = nil
        
        simulationTimer?.invalidate()
        simulationTimer = nil
        
        heartRateHistory.removeAll()
        movementHistory.removeAll()
    }
    
    // MARK: - Simulation for Testing
    
    private func startSimulation() {
        simulationTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.simulateData()
        }
    }
    
    private func simulateData() {
        // Simulate heart rate and movement data
        let baseHeartRate = 70.0
        let heartRateVariation = Double.random(in: -20...20)
        currentHeartRate = baseHeartRate + heartRateVariation
        
        currentMovement = Double.random(in: 0...0.5)
        
        heartRateHistory.append((Date(), currentHeartRate))
        movementHistory.append((Date(), currentMovement))
        
        // Keep only recent history
        cleanOldData()
        analyzeSleepState()
    }
    
    // MARK: - Sleep State Analysis
    
    private func analyzeSleepState() {
        guard let startTime = monitoringStartTime,
              Date().timeIntervalSince(startTime) >= sleepDetectionDuration else {
            return
        }
        
        let recentHeartRates = heartRateHistory.suffix(10).map { $0.1 }
        let recentMovement = movementHistory.suffix(5).map { $0.1 }
        
        guard !recentHeartRates.isEmpty else { return }
        
        let avgHeartRate = recentHeartRates.reduce(0, +) / Double(recentHeartRates.count)
        let avgMovement = recentMovement.isEmpty ? 0 : recentMovement.reduce(0, +) / Double(recentMovement.count)
        
        let newSleepState = determineSleepState(heartRate: avgHeartRate, movement: avgMovement)
        
        if newSleepState != sleepState {
            let previousState = sleepState
            sleepState = newSleepState
            
            // Post notification about sleep state change
            NotificationCenter.default.post(
                name: .sleepStateChanged,
                object: SleepStateChange(from: previousState, to: newSleepState, timestamp: Date())
            )
        }
    }
    
    private func determineSleepState(heartRate: Double, movement: Double) -> SleepState {
        if heartRate < sleepHeartRateThreshold && movement < movementThreshold {
            return .asleep
        } else if heartRate > awakeHeartRateThreshold || movement > movementThreshold * 2 {
            return .awake
        } else {
            return .drowsy
        }
    }
    
    private func cleanOldData() {
        let cutoffTime = Date().addingTimeInterval(-1800) // Keep 30 minutes of data
        
        heartRateHistory.removeAll { $0.0 < cutoffTime }
        movementHistory.removeAll { $0.0 < cutoffTime }
    }
}

/// Sleep states
public enum SleepState: String, CaseIterable {
    case awake = "Awake"
    case drowsy = "Drowsy"
    case asleep = "Asleep"
}

/// Sleep state change event
public struct SleepStateChange {
    public let from: SleepState
    public let to: SleepState
    public let timestamp: Date
    
    public init(from: SleepState, to: SleepState, timestamp: Date) {
        self.from = from
        self.to = to
        self.timestamp = timestamp
    }
}

// MARK: - Notifications

public extension Notification.Name {
    static let sleepStateChanged = Notification.Name("sleepStateChanged")
}