import SwiftUI
import PuzzAlarmCore

struct WatchAddAlarmView: View {
    @ObservedObject var alarmManager: ObservableWatchAlarmManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var time = Date()
    @State private var label = "Alarm"
    @State private var puzzleType: PuzzleType? = nil
    @State private var isEnabled = true
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                }
                
                Section("Details") {
                    TextField("Label", text: $label)
                    
                    Picker("Challenge", selection: $puzzleType) {
                        Text("None").tag(nil as PuzzleType?)
                        Text("Math").tag(PuzzleType.math as PuzzleType?)
                        Text("Water").tag(PuzzleType.water as PuzzleType?)
                    }
                }
            }
            .navigationTitle("New Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
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
            puzzleType: puzzleType,
            puzzleSettings: PuzzleSettings()
        )
        
        alarmManager.addAlarm(alarm)
        dismiss()
    }
}

#Preview {
    WatchAddAlarmView(alarmManager: ObservableWatchAlarmManager())
}