import Foundation
import HealthKit
import PuzzAlarmCore

/// Manages HealthKit integration for sleep detection on Apple Watch
class HealthManager: ObservableObject {
    static let shared = HealthManager()
    
    private let healthStore = HKHealthStore()
    @Published var isHealthKitAvailable = false
    @Published var hasHealthKitPermission = false
    @Published var currentHeartRate: Double = 0
    @Published var sleepState: SleepState = .awake
    
    // HealthKit data types we need
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    private let sleepAnalysisType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
    
    private init() {
        isHealthKitAvailable = HKHealthStore.isHealthDataAvailable()
    }
    
    /// Request permission to access HealthKit data
    func requestHealthKitPermission() {
        guard isHealthKitAvailable else { return }
        
        let readTypes: Set<HKObjectType> = [heartRateType, sleepAnalysisType]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.hasHealthKitPermission = success
                if success {
                    self?.startHealthDataCollection()
                }
            }
        }
    }
    
    /// Start collecting health data for sleep detection
    private func startHealthDataCollection() {
        startHeartRateMonitoring()
        startSleepAnalysis()
    }
    
    /// Monitor heart rate for sleep detection
    private func startHeartRateMonitoring() {
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, anchor, error in
            self?.processHeartRateSamples(samples)
        }
        
        query.updateHandler = { [weak self] query, samples, deletedObjects, anchor, error in
            self?.processHeartRateSamples(samples)
        }
        
        healthStore.execute(query)
    }
    
    /// Process heart rate samples for sleep detection
    private func processHeartRateSamples(_ samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else { return }
        
        for sample in heartRateSamples {
            let heartRateValue = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            
            DispatchQueue.main.async {
                self.currentHeartRate = heartRateValue
                self.updateSleepState(heartRate: heartRateValue)
            }
        }
    }
    
    /// Monitor sleep analysis data
    private func startSleepAnalysis() {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: sleepAnalysisType,
            predicate: nil,
            limit: 10,
            sortDescriptors: [sortDescriptor]
        ) { [weak self] query, samples, error in
            self?.processSleepSamples(samples)
        }
        
        healthStore.execute(query)
    }
    
    /// Process sleep analysis samples
    private func processSleepSamples(_ samples: [HKSample]?) {
        guard let sleepSamples = samples as? [HKCategorySample] else { return }
        
        for sample in sleepSamples {
            let sleepValue = sample.value
            
            DispatchQueue.main.async {
                // Map HKCategoryValueSleepAnalysis to our SleepState
                switch sleepValue {
                case HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
                     HKCategoryValueSleepAnalysis.asleepCore.rawValue,
                     HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
                     HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                    self.sleepState = .asleep
                case HKCategoryValueSleepAnalysis.awake.rawValue:
                    self.sleepState = .awake
                default:
                    self.sleepState = .awake
                }
            }
        }
    }
    
    /// Update sleep state based on heart rate and other factors
    private func updateSleepState(heartRate: Double) {
        // Simple heuristic for sleep detection based on heart rate
        // In a real implementation, this would be more sophisticated
        let restingHeartRateThreshold: Double = 60
        let sleepHeartRateThreshold: Double = 55
        
        if heartRate < sleepHeartRateThreshold {
            if sleepState != .asleep {
                sleepState = .asleep
                notifySleepStateChange(from: .awake, to: .asleep)
            }
        } else if heartRate > restingHeartRateThreshold {
            if sleepState != .awake {
                sleepState = .awake
                notifySleepStateChange(from: .asleep, to: .awake)
            }
        }
    }
    
    /// Notify when sleep state changes
    private func notifySleepStateChange(from: SleepState, to: SleepState) {
        let transition = SleepStateTransition(from: from, to: to, timestamp: Date())
        
        NotificationCenter.default.post(
            name: .sleepStateChanged,
            object: transition
        )
    }
    
    /// Check if user fell back asleep after an alarm
    func checkForFallAsleepAfterAlarm(alarmId: UUID, completion: @escaping (Bool) -> Void) {
        // Monitor for sleep state changes for the next 30 minutes
        DispatchQueue.main.asyncAfter(deadline: .now() + 1800) { // 30 minutes
            completion(self.sleepState == .asleep)
        }
    }
}