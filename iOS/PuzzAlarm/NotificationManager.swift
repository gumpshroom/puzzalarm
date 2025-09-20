import Foundation
import UserNotifications
import PuzzAlarmCore

/// Manages user notifications for alarms
public class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    public static let shared = NotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    /// Requests notification permissions from the user
    public func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    /// Schedules a notification for an alarm
    public func scheduleNotification(for alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "Alarm"
        content.body = alarm.label
        content.sound = alarm.isSilentMode ? nil : UNNotificationSound.default
        content.userInfo = ["alarmId": alarm.id.uuidString]
        
        // Create date components for the alarm time
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: alarm.time)
        
        if alarm.repeatDays.isEmpty {
            // One-time alarm
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: alarm.id.uuidString, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        } else {
            // Recurring alarm
            for weekday in alarm.repeatDays {
                var components = dateComponents
                components.weekday = weekdayToCalendarWeekday(weekday)
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(
                    identifier: "\(alarm.id.uuidString)-\(weekday.rawValue)",
                    content: content,
                    trigger: trigger
                )
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error scheduling recurring notification: \(error)")
                    }
                }
            }
        }
    }
    
    /// Cancels a scheduled notification
    public func cancelNotification(for alarmId: UUID) {
        let identifiers = [alarmId.uuidString] + Weekday.allCases.map { "\(alarmId.uuidString)-\($0.rawValue)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    /// Cancels all scheduled notifications
    public func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.alert, .sound, .badge])
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let alarmIdString = response.notification.request.content.userInfo["alarmId"] as? String,
           let alarmId = UUID(uuidString: alarmIdString) {
            
            // Post notification that alarm was triggered
            NotificationCenter.default.post(
                name: .alarmTriggered,
                object: alarmId
            )
        }
        
        completionHandler()
    }
    
    // MARK: - Helper Methods
    
    private func weekdayToCalendarWeekday(_ weekday: Weekday) -> Int {
        switch weekday {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }
}