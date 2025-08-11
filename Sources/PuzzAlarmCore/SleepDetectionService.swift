import Foundation

#if canImport(Combine)
import Combine
#endif

#if canImport(HealthKit)
import HealthKit
#endif

/// Sleep detection service for WatchOS using biometric data
#if canImport(HealthKit)
#if canImport(Combine)
public class SleepDetectionService: ObservableObject {
    @Published public var isMonitoring: Bool = false
    @Published public var currentHeartRate: Double = 0
    @Published public var currentMovement: Double = 0
    @Published public var sleepState: SleepState = .awake
#else
public class SleepDetectionService {
    public var isMonitoring: Bool = false
    public var currentHeartRate: Double = 0
    public var currentMovement: Double = 0
    public var sleepState: SleepState = .awake
#endif
    
    private let healthStore = HKHealthStore()
    private var heartRateQuery: HKAnchoredObjectQuery?
    private var movementTimer: Timer?
    private var monitoringStartTime: Date?
    
    // Thresholds for sleep detection
    private let sleepHeartRateThreshold: Double = 60 // BPM below which suggests sleep
    private let awakeHeartRateThreshold: Double = 80 // BPM above which suggests awake
    private let movementThreshold: Double = 0.1 // Movement threshold for sleep detection
    private let sleepDetectionDuration: TimeInterval = 300 // 5 minutes of consistent data
    
    private var heartRateHistory: [(Date, Double)] = []
    private var movementHistory: [(Date, Double)] = []
    
    public init() {
        requestHealthKitAuthorization()
    }
    
    // MARK: - Public Methods
    
    public func startMonitoring() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        isMonitoring = true
        monitoringStartTime = Date()
        sleepState = .awake
        
        startHeartRateMonitoring()
        startMovementMonitoring()
    }
    
    public func stopMonitoring() {
        isMonitoring = false
        monitoringStartTime = nil
        
        heartRateQuery?.stop()
        heartRateQuery = nil
        movementTimer?.invalidate()
        movementTimer = nil
        
        heartRateHistory.removeAll()
        movementHistory.removeAll()
    }
    
    // MARK: - HealthKit Authorization
    
    private func requestHealthKitAuthorization() {
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if let error = error {
                print("HealthKit authorization failed: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Heart Rate Monitoring
    
    private func startHeartRateMonitoring() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, anchor, error in
            self?.processHeartRatesamples(samples)
        }
        
        query.updateHandler = { [weak self] query, samples, deletedObjects, anchor, error in
            self?.processHeartRatesamples(samples)
        }
        
        healthStore.execute(query)
        heartRateQuery = query
    }
    
    private func processHeartRatesamples(_ samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample] else { return }
        
        DispatchQueue.main.async {
            for sample in samples {
                let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                self.currentHeartRate = heartRate
                self.heartRateHistory.append((sample.startDate, heartRate))
                
                // Keep only recent history
                self.cleanOldData()
                self.analyzeSleepState()
            }
        }
    }
    
    // MARK: - Movement Monitoring
    
    private func startMovementMonitoring() {
        movementTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.queryRecentMovement()
        }
    }
    
    private func queryRecentMovement() {
        let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let now = Date()
        let thirtySecondsAgo = now.addingTimeInterval(-30)
        
        let predicate = HKQuery.predicateForSamples(withStart: thirtySecondsAgo, end: now, options: .strictStartDate)
        
        let query = HKSampleQuery(
            sampleType: energyType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { [weak self] query, samples, error in
            self?.processMovementSamples(samples)
        }
        
        healthStore.execute(query)
    }
    
    private func processMovementSamples(_ samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample] else { return }
        
        let totalEnergy = samples.reduce(0.0) { total, sample in
            return total + sample.quantity.doubleValue(for: HKUnit.kilocalorie())
        }
        
        DispatchQueue.main.async {
            self.currentMovement = totalEnergy
            self.movementHistory.append((Date(), totalEnergy))
            
            self.cleanOldData()
            self.analyzeSleepState()
        }
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
#else
// Stub implementation for platforms without HealthKit
public class SleepDetectionService {
    public var isMonitoring: Bool = false
    public var currentHeartRate: Double = 0
    public var currentMovement: Double = 0
    public var sleepState: SleepState = .awake
    
    public init() {}
    
    public func startMonitoring() {
        isMonitoring = true
    }
    
    public func stopMonitoring() {
        isMonitoring = false
    }
}
#endif

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