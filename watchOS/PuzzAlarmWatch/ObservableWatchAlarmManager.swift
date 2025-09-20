import SwiftUI
import Combine
import PuzzAlarmCore

/// watchOS wrapper for AlarmManager that adds ObservableObject functionality
class ObservableWatchAlarmManager: ObservableObject {
    @Published var alarms: [Alarm] = []
    @Published var statistics: GlobalStatistics = GlobalStatistics()
    
    private let coreManager = AlarmManager()
    private let healthManager = HealthManager.shared
    
    init() {
        syncFromCore()
        setupNotificationObservers()
    }
    
    func addAlarm(_ alarm: Alarm) {
        coreManager.addAlarm(alarm)
        syncFromCore()
    }
    
    func updateAlarm(_ alarm: Alarm) {
        coreManager.updateAlarm(alarm)
        syncFromCore()
    }
    
    func deleteAlarm(_ alarm: Alarm) {
        coreManager.deleteAlarm(alarm)
        syncFromCore()
    }
    
    func toggleAlarm(_ alarmId: UUID) {
        coreManager.toggleAlarm(alarmId)
        syncFromCore()
    }
    
    func triggerAlarm(_ alarmId: UUID) {
        coreManager.triggerAlarm(alarmId)
        syncFromCore()
        
        // Start monitoring for falling back asleep
        healthManager.checkForFallAsleepAfterAlarm(alarmId: alarmId) { [weak self] fellAsleep in
            if fellAsleep {
                // User fell back asleep, trigger alarm again
                self?.triggerAlarm(alarmId)
            }
        }
    }
    
    func snoozeAlarm(_ alarmId: UUID) {
        coreManager.snoozeAlarm(alarmId)
        syncFromCore()
    }
    
    func dismissAlarm(_ alarmId: UUID, puzzleCompletionTime: TimeInterval? = nil) {
        coreManager.dismissAlarm(alarmId, puzzleCompletionTime: puzzleCompletionTime)
        syncFromCore()
    }
    
    private func syncFromCore() {
        DispatchQueue.main.async {
            self.alarms = self.coreManager.alarms
            self.statistics = self.coreManager.statistics
        }
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: .alarmTriggered,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.syncFromCore()
        }
        
        NotificationCenter.default.addObserver(
            forName: .alarmDismissed,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.syncFromCore()
        }
        
        NotificationCenter.default.addObserver(
            forName: .sleepStateChanged,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let transition = notification.object as? SleepStateTransition {
                self?.handleSleepStateChange(transition)
            }
        }
    }
    
    private func handleSleepStateChange(_ transition: SleepStateTransition) {
        // Log sleep state changes for statistics
        // This could be enhanced to automatically trigger alarms if user falls back asleep
        print("Sleep state changed from \(transition.from) to \(transition.to)")
    }
}