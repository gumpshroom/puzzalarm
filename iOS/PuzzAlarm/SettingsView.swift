import SwiftUI
import PuzzAlarmCore

struct SettingsView: View {
    @ObservedObject var alarmManager: ObservableAlarmManager
    @State private var globalSoundEnabled = true
    @State private var defaultSnoozeTime = 9.0 // minutes
    @State private var vibrationEnabled = true
    @State private var hapticFeedbackEnabled = true
    @State private var showStatistics = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("General") {
                    Toggle("Global Sound", isOn: $globalSoundEnabled)
                    
                    Toggle("Vibration", isOn: $vibrationEnabled)
                    
                    Toggle("Haptic Feedback", isOn: $hapticFeedbackEnabled)
                }
                
                Section("Snooze Settings") {
                    VStack(alignment: .leading) {
                        Text("Default Snooze Time")
                        HStack {
                            Text("\(Int(defaultSnoozeTime)) minutes")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        Slider(value: $defaultSnoozeTime, in: 1...30, step: 1)
                    }
                }
                
                Section("Statistics") {
                    Button("View Statistics") {
                        showStatistics = true
                    }
                    
                    HStack {
                        Text("Total Alarms Created")
                        Spacer()
                        Text("\(alarmManager.statistics.totalAlarmsCreated)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Total Alarms Triggered")
                        Spacer()
                        Text("\(alarmManager.statistics.totalAlarmsTriggered)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Total Snoozes")
                        Spacer()
                        Text("\(alarmManager.statistics.totalSnoozes)")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link("Support", destination: URL(string: "https://example.com/support")!)
                    
                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showStatistics) {
                StatisticsView(statistics: alarmManager.statistics)
            }
        }
    }
}

struct StatisticsView: View {
    let statistics: GlobalStatistics
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Overview") {
                    StatRow(title: "Total Alarms Created", value: "\(statistics.totalAlarmsCreated)")
                    StatRow(title: "Total Alarms Triggered", value: "\(statistics.totalAlarmsTriggered)")
                    StatRow(title: "Total Snoozes", value: "\(statistics.totalSnoozes)")
                    
                    if let averageWakeUpTime = statistics.averageWakeUpTime {
                        StatRow(title: "Average Wake-up Time", value: timeString(averageWakeUpTime))
                    }
                    
                    StatRow(title: "Longest Sleep Streak", value: "\(statistics.longestSleepStreak) days")
                }
                
                if let mostUsedPuzzle = statistics.mostUsedPuzzleType {
                    Section("Puzzle Stats") {
                        StatRow(title: "Most Used Puzzle", value: mostUsedPuzzle.displayName)
                    }
                }
                
                Section("Individual Alarms") {
                    ForEach(Array(statistics.alarmStatistics.values), id: \.alarmId) { alarmStats in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Alarm \(alarmStats.alarmId.uuidString.prefix(8))")
                                .font(.headline)
                            
                            StatRow(title: "Triggers", value: "\(alarmStats.totalTriggers)")
                            StatRow(title: "Snoozes", value: "\(alarmStats.totalSnoozes)")
                            StatRow(title: "Avg Puzzle Time", value: "\(Int(alarmStats.averagePuzzleCompletionTime))s")
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    SettingsView(alarmManager: ObservableAlarmManager())
}