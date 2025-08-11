import Foundation

#if canImport(Combine)
import Combine
#endif

/// Main manager for handling alarms and notifications
#if canImport(Combine)
public class AlarmManager: ObservableObject {
    @Published public var alarms: [Alarm] = []
    @Published public var statistics: GlobalStatistics = GlobalStatistics()
#else
public class AlarmManager {
    public var alarms: [Alarm] = []
    public var statistics: GlobalStatistics = GlobalStatistics()
#endif
    
    private let userDefaults = UserDefaults.standard
    private let alarmsKey = "savedAlarms"
    private let statisticsKey = "globalStatistics"
    
    public init() {
        loadAlarms()
        loadStatistics()
    }
    
    // MARK: - Alarm Management
    
    public func addAlarm(_ alarm: Alarm) {
        alarms.append(alarm)
        statistics.addAlarm(alarm)
        saveAlarms()
        saveStatistics()
        scheduleNotification(for: alarm)
    }
    
    public func updateAlarm(_ alarm: Alarm) {
        guard let index = alarms.firstIndex(where: { $0.id == alarm.id }) else { return }
        alarms[index] = alarm
        saveAlarms()
        
        // Reschedule notification
        cancelNotification(for: alarm.id)
        if alarm.isEnabled {
            scheduleNotification(for: alarm)
        }
    }
    
    public func deleteAlarm(_ alarm: Alarm) {
        alarms.removeAll { $0.id == alarm.id }
        statistics.alarmStatistics.removeValue(forKey: alarm.id)
        saveAlarms()
        saveStatistics()
        cancelNotification(for: alarm.id)
    }
    
    public func toggleAlarm(_ alarmId: UUID) {
        guard let index = alarms.firstIndex(where: { $0.id == alarmId }) else { return }
        alarms[index].isEnabled.toggle()
        
        if alarms[index].isEnabled {
            scheduleNotification(for: alarms[index])
        } else {
            cancelNotification(for: alarmId)
        }
        
        saveAlarms()
    }
    
    // MARK: - Notification Scheduling
    
    private func scheduleNotification(for alarm: Alarm) {
        // This would integrate with iOS UserNotifications framework
        // For now, we'll create a placeholder implementation
        print("Scheduling notification for alarm: \(alarm.label) at \(alarm.time)")
    }
    
    private func cancelNotification(for alarmId: UUID) {
        // This would cancel the scheduled notification
        print("Cancelling notification for alarm: \(alarmId)")
    }
    
    // MARK: - Alarm Triggering
    
    public func triggerAlarm(_ alarmId: UUID) {
        guard let alarm = alarms.first(where: { $0.id == alarmId }) else { return }
        statistics.recordAlarmTrigger(alarmId: alarmId)
        saveStatistics()
        
        // Post notification that alarm was triggered
        NotificationCenter.default.post(
            name: .alarmTriggered,
            object: alarm
        )
    }
    
    public func snoozeAlarm(_ alarmId: UUID) {
        statistics.recordSnooze(alarmId: alarmId)
        saveStatistics()
        
        // Reschedule for snooze time (typically 9 minutes)
        // This is a simplified implementation
        print("Snoozing alarm: \(alarmId)")
    }
    
    public func dismissAlarm(_ alarmId: UUID, puzzleCompletionTime: TimeInterval? = nil) {
        if let completionTime = puzzleCompletionTime {
            statistics.recordPuzzleCompletion(alarmId: alarmId, time: completionTime)
            saveStatistics()
        }
        
        // Post notification that alarm was dismissed
        NotificationCenter.default.post(
            name: .alarmDismissed,
            object: alarmId
        )
    }
    
    // MARK: - Persistence
    
    private func saveAlarms() {
        if let encoded = try? JSONEncoder().encode(alarms) {
            userDefaults.set(encoded, forKey: alarmsKey)
        }
    }
    
    private func loadAlarms() {
        guard let data = userDefaults.data(forKey: alarmsKey),
              let decoded = try? JSONDecoder().decode([Alarm].self, from: data) else {
            return
        }
        alarms = decoded
    }
    
    private func saveStatistics() {
        if let encoded = try? JSONEncoder().encode(statistics) {
            userDefaults.set(encoded, forKey: statisticsKey)
        }
    }
    
    private func loadStatistics() {
        guard let data = userDefaults.data(forKey: statisticsKey),
              let decoded = try? JSONDecoder().decode(GlobalStatistics.self, from: data) else {
            return
        }
        statistics = decoded
    }
}

// MARK: - Notifications

public extension Notification.Name {
    static let alarmTriggered = Notification.Name("alarmTriggered")
    static let alarmDismissed = Notification.Name("alarmDismissed")
    static let puzzleCompleted = Notification.Name("puzzleCompleted")
}