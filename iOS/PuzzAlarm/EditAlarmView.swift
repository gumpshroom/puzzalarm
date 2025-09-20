import SwiftUI
import PuzzAlarmCore

struct EditAlarmView: View {
    let alarm: Alarm
    @ObservedObject var alarmManager: ObservableAlarmManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var time: Date
    @State private var label: String
    @State private var isEnabled: Bool
    @State private var puzzleType: PuzzleType?
    @State private var repeatDays: Set<Weekday>
    @State private var soundName: String
    @State private var vibrationPattern: VibrationPattern
    @State private var isSilentMode: Bool
    @State private var isGradualWakeup: Bool
    @State private var snoozeEnabled: Bool
    @State private var puzzleSettings: PuzzleSettings
    
    init(alarm: Alarm, alarmManager: ObservableAlarmManager) {
        self.alarm = alarm
        self.alarmManager = alarmManager
        
        // Initialize state from alarm
        _time = State(initialValue: alarm.time)
        _label = State(initialValue: alarm.label)
        _isEnabled = State(initialValue: alarm.isEnabled)
        _puzzleType = State(initialValue: alarm.puzzleType)
        _repeatDays = State(initialValue: alarm.repeatDays)
        _soundName = State(initialValue: alarm.soundName)
        _vibrationPattern = State(initialValue: alarm.vibrationPattern)
        _isSilentMode = State(initialValue: alarm.isSilentMode)
        _isGradualWakeup = State(initialValue: alarm.isGradualWakeup)
        _snoozeEnabled = State(initialValue: alarm.snoozeEnabled)
        _puzzleSettings = State(initialValue: alarm.puzzleSettings)
    }
    
    var body: some View {
        Form {
            Section {
                DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
            }
            
            Section("Alarm Details") {
                TextField("Label", text: $label)
                
                if !isSilentMode {
                    TextField("Sound", text: $soundName)
                }
                
                Toggle("Silent Mode", isOn: $isSilentMode)
                
                if !isSilentMode {
                    Picker("Vibration", selection: $vibrationPattern) {
                        ForEach(VibrationPattern.allCases, id: \.self) { pattern in
                            Text(pattern.displayName).tag(pattern)
                        }
                    }
                }
                
                Toggle("Gradual Wake-up", isOn: $isGradualWakeup)
                Toggle("Snooze", isOn: $snoozeEnabled)
            }
            
            Section("Repeat") {
                ForEach(Weekday.allCases, id: \.self) { day in
                    Toggle(day.fullName, isOn: Binding(
                        get: { repeatDays.contains(day) },
                        set: { isSelected in
                            if isSelected {
                                repeatDays.insert(day)
                            } else {
                                repeatDays.remove(day)
                            }
                        }
                    ))
                }
            }
            
            Section("Puzzle Challenge") {
                Picker("Puzzle Type", selection: $puzzleType) {
                    Text("None").tag(nil as PuzzleType?)
                    ForEach(PuzzleType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type as PuzzleType?)
                    }
                }
                
                if puzzleType != nil {
                    NavigationLink("Puzzle Settings") {
                        PuzzleSettingsView(puzzleType: puzzleType!, settings: $puzzleSettings)
                    }
                }
            }
            
            Section {
                Button("Delete Alarm", role: .destructive) {
                    deleteAlarm()
                }
            }
        }
        .navigationTitle("Edit Alarm")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveAlarm()
                }
            }
        }
    }
    
    private func saveAlarm() {
        let updatedAlarm = Alarm(
            id: alarm.id, // Keep the same ID
            time: time,
            isEnabled: isEnabled,
            label: label,
            soundName: soundName,
            vibrationPattern: vibrationPattern,
            isSilentMode: isSilentMode,
            isGradualWakeup: isGradualWakeup,
            snoozeEnabled: snoozeEnabled,
            repeatDays: repeatDays,
            puzzleType: puzzleType,
            puzzleSettings: puzzleSettings
        )
        
        alarmManager.updateAlarm(updatedAlarm)
        
        // Update notification if alarm is enabled
        if updatedAlarm.isEnabled {
            NotificationManager.shared.cancelNotification(for: updatedAlarm.id)
            NotificationManager.shared.scheduleNotification(for: updatedAlarm)
        } else {
            NotificationManager.shared.cancelNotification(for: updatedAlarm.id)
        }
        
        dismiss()
    }
    
    private func deleteAlarm() {
        NotificationManager.shared.cancelNotification(for: alarm.id)
        alarmManager.deleteAlarm(alarm)
        dismiss()
    }
}

#Preview {
    NavigationView {
        EditAlarmView(
            alarm: Alarm(
                time: Date(),
                isEnabled: true,
                label: "Wake Up",
                puzzleType: .math,
                puzzleSettings: PuzzleSettings()
            ),
            alarmManager: ObservableAlarmManager()
        )
    }
}