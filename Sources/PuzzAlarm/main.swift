import SwiftUI

@main
struct PuzzAlarmApp: App {
    @StateObject private var alarmManager = AlarmManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(alarmManager)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    @State private var showingAddAlarm = false
    
    var body: some View {
        NavigationView {
            AlarmListView()
                .navigationTitle("PuzzAlarm")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Add") {
                            showingAddAlarm = true
                        }
                    }
                }
                .sheet(isPresented: $showingAddAlarm) {
                    AddAlarmView()
                }
        }
    }
}

struct AlarmListView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    
    var body: some View {
        List {
            ForEach(alarmManager.alarms) { alarm in
                AlarmRowView(alarm: alarm)
            }
            .onDelete(perform: deleteAlarms)
        }
        .listStyle(PlainListStyle())
    }
    
    private func deleteAlarms(offsets: IndexSet) {
        for index in offsets {
            let alarm = alarmManager.alarms[index]
            alarmManager.deleteAlarm(alarm)
        }
    }
}

struct AlarmRowView: View {
    let alarm: Alarm
    @EnvironmentObject var alarmManager: AlarmManager
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(timeFormatter.string(from: alarm.time))
                    .font(.system(size: 32, weight: .light, design: .default))
                    .foregroundColor(alarm.isEnabled ? .primary : .secondary)
                
                Text(alarm.label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if !alarm.repeatDays.isEmpty {
                    Text(repeatDaysText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let puzzleType = alarm.puzzleType {
                    HStack {
                        Image(systemName: "puzzlepiece.extension")
                            .font(.caption)
                        Text(puzzleType.displayName)
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { alarm.isEnabled },
                set: { _ in alarmManager.toggleAlarm(alarm.id) }
            ))
            .labelsHidden()
        }
        .padding(.vertical, 8)
    }
    
    private var repeatDaysText: String {
        let sortedDays = alarm.repeatDays.sorted { day1, day2 in
            let weekdays: [Weekday] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
            return weekdays.firstIndex(of: day1)! < weekdays.firstIndex(of: day2)!
        }
        return sortedDays.map { $0.rawValue }.joined(separator: " ")
    }
}

struct AddAlarmView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var alarmManager: AlarmManager
    
    @State private var selectedTime = Date()
    @State private var label = "Alarm"
    @State private var selectedSound = "default"
    @State private var vibrationPattern = VibrationPattern.standard
    @State private var isSilentMode = false
    @State private var isGradualWakeup = false
    @State private var selectedDays: Set<Weekday> = []
    @State private var selectedPuzzleType: PuzzleType? = nil
    @State private var puzzleSettings = PuzzleSettings()
    
    let soundOptions = ["default", "chime", "bell", "electronic"]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                }
                
                Section("Details") {
                    TextField("Label", text: $label)
                    
                    Picker("Sound", selection: $selectedSound) {
                        ForEach(soundOptions, id: \.self) { sound in
                            Text(sound.capitalized).tag(sound)
                        }
                    }
                    
                    Picker("Vibration", selection: $vibrationPattern) {
                        ForEach(VibrationPattern.allCases, id: \.self) { pattern in
                            Text(pattern.rawValue).tag(pattern)
                        }
                    }
                    
                    Toggle("Silent Mode", isOn: $isSilentMode)
                    Toggle("Gradual Wake Up", isOn: $isGradualWakeup)
                }
                
                Section("Repeat") {
                    ForEach(Weekday.allCases, id: \.self) { day in
                        Button(action: {
                            if selectedDays.contains(day) {
                                selectedDays.remove(day)
                            } else {
                                selectedDays.insert(day)
                            }
                        }) {
                            HStack {
                                Text(day.fullName)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedDays.contains(day) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                Section("Puzzle") {
                    Picker("Puzzle Type", selection: $selectedPuzzleType) {
                        Text("None").tag(nil as PuzzleType?)
                        ForEach(PuzzleType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type as PuzzleType?)
                        }
                    }
                    
                    if selectedPuzzleType != nil {
                        NavigationLink("Puzzle Settings") {
                            PuzzleSettingsView(settings: $puzzleSettings, puzzleType: selectedPuzzleType!)
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
            time: selectedTime,
            label: label,
            soundName: selectedSound,
            vibrationPattern: vibrationPattern,
            isSilentMode: isSilentMode,
            isGradualWakeup: isGradualWakeup,
            repeatDays: selectedDays,
            puzzleType: selectedPuzzleType,
            puzzleSettings: puzzleSettings
        )
        
        alarmManager.addAlarm(alarm)
        dismiss()
    }
}

struct PuzzleSettingsView: View {
    @Binding var settings: PuzzleSettings
    let puzzleType: PuzzleType
    
    var body: some View {
        Form {
            switch puzzleType {
            case .math:
                mathPuzzleSettings
            case .marbleMaze:
                mazePuzzleSettings
            case .water:
                waterPuzzleSettings
            }
        }
        .navigationTitle("Puzzle Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var mathPuzzleSettings: some View {
        Group {
            Section("Math Puzzle") {
                Picker("Difficulty", selection: $settings.mathDifficulty) {
                    ForEach(MathDifficulty.allCases, id: \.self) { difficulty in
                        Text(difficulty.rawValue).tag(difficulty)
                    }
                }
                
                Stepper("Problems: \(settings.mathProblemCount)", value: $settings.mathProblemCount, in: 1...10)
                
                VStack(alignment: .leading) {
                    Text("Time Limit: \(Int(settings.mathTimeLimit)) seconds")
                    Slider(value: $settings.mathTimeLimit, in: 30...300, step: 30)
                }
            }
        }
    }
    
    private var mazePuzzleSettings: some View {
        Group {
            Section("Marble Maze") {
                Picker("Difficulty", selection: $settings.mazeDifficulty) {
                    ForEach(MazeDifficulty.allCases, id: \.self) { difficulty in
                        Text(difficulty.rawValue).tag(difficulty)
                    }
                }
                
                Stepper("Completions: \(settings.mazeCompletionCount)", value: $settings.mazeCompletionCount, in: 1...5)
            }
        }
    }
    
    private var waterPuzzleSettings: some View {
        Group {
            Section("Water Puzzle") {
                Stepper("Completions: \(settings.waterCompletionCount)", value: $settings.waterCompletionCount, in: 1...5)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AlarmManager())
}