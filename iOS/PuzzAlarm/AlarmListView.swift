import SwiftUI
import PuzzAlarmCore

struct AlarmListView: View {
    @ObservedObject var alarmManager: ObservableAlarmManager
    
    var body: some View {
        List {
            ForEach(alarmManager.alarms, id: \.id) { alarm in
                AlarmRowView(alarm: alarm, alarmManager: alarmManager)
            }
            .onDelete(perform: deleteAlarms)
        }
        .listStyle(.plain)
    }
    
    private func deleteAlarms(offsets: IndexSet) {
        for index in offsets {
            let alarm = alarmManager.alarms[index]
            NotificationManager.shared.cancelNotification(for: alarm.id)
            alarmManager.deleteAlarm(alarm)
        }
    }
}

struct AlarmRowView: View {
    let alarm: Alarm
    @ObservedObject var alarmManager: ObservableAlarmManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(timeString)
                    .font(.system(size: 48, weight: .thin, design: .default))
                    .foregroundColor(alarm.isEnabled ? .primary : .secondary)
                
                HStack {
                    Text(alarm.label)
                        .font(.body)
                        .foregroundColor(alarm.isEnabled ? .primary : .secondary)
                    
                    if let puzzleType = alarm.puzzleType {
                        Spacer()
                        Text(puzzleType.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if !alarm.repeatDays.isEmpty {
                    Text(repeatDaysString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { alarm.isEnabled },
                set: { isEnabled in 
                    alarmManager.toggleAlarm(alarm.id)
                    if isEnabled {
                        NotificationManager.shared.scheduleNotification(for: alarm)
                    } else {
                        NotificationManager.shared.cancelNotification(for: alarm.id)
                    }
                }
            ))
            .toggleStyle(SwitchToggleStyle())
        }
        .padding(.vertical, 8)
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: alarm.time)
    }
    
    private var repeatDaysString: String {
        if alarm.repeatDays.count == 7 {
            return "Every Day"
        } else if alarm.repeatDays.count == 5 && !alarm.repeatDays.contains(.saturday) && !alarm.repeatDays.contains(.sunday) {
            return "Weekdays"
        } else if alarm.repeatDays.count == 2 && alarm.repeatDays.contains(.saturday) && alarm.repeatDays.contains(.sunday) {
            return "Weekends"
        } else {
            return alarm.repeatDays.map { $0.abbreviation }.joined(separator: " ")
        }
    }
}

#Preview {
    let manager = ObservableAlarmManager()
    let alarm = Alarm(
        time: Date(),
        isEnabled: true,
        label: "Wake Up",
        puzzleType: .math,
        puzzleSettings: PuzzleSettings()
    )
    manager.addAlarm(alarm)
    
    return NavigationView {
        AlarmListView(alarmManager: manager)
            .navigationTitle("Alarms")
    }
}