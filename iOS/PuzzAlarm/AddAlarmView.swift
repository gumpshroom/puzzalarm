import SwiftUI
import PuzzAlarmCore

struct AddAlarmView: View {
    @ObservedObject var alarmManager: ObservableAlarmManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var time = Date()
    @State private var label = "Alarm"
    @State private var isEnabled = true
    @State private var puzzleType: PuzzleType? = nil
    @State private var repeatDays: Set<Weekday> = []
    @State private var soundName = "default"
    @State private var vibrationPattern: VibrationPattern = .standard
    @State private var isSilentMode = false
    @State private var isGradualWakeup = false
    @State private var snoozeEnabled = true
    @State private var puzzleSettings = PuzzleSettings()
    
    var body: some View {
        NavigationView {
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
            }
            .navigationTitle("New Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAlarm()
                    }
                }
            }
        }
    }
    
    private func saveAlarm() {
        let alarm = Alarm(
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
        
        alarmManager.addAlarm(alarm)
        
        // Schedule notification if alarm is enabled
        if alarm.isEnabled {
            NotificationManager.shared.scheduleNotification(for: alarm)
        }
        
        dismiss()
    }
}

#Preview {
    AddAlarmView(alarmManager: ObservableAlarmManager())
}