import SwiftUI
import Combine
import PuzzAlarmCore

/// iOS wrapper for AlarmManager that adds ObservableObject functionality
class ObservableAlarmManager: ObservableObject {
    @Published var alarms: [Alarm] = []
    @Published var statistics: GlobalStatistics = GlobalStatistics()
    
    private let coreManager = AlarmManager()
    
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
    }
}