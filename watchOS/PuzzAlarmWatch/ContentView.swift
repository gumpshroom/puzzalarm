import SwiftUI
import PuzzAlarmCore
import HealthKit

struct ContentView: View {
    @StateObject private var alarmManager = ObservableWatchAlarmManager()
    @StateObject private var healthManager = HealthManager.shared
    @State private var showingAddAlarm = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(alarmManager.alarms, id: \.id) { alarm in
                    WatchAlarmRowView(alarm: alarm, alarmManager: alarmManager)
                }
                .onDelete(perform: deleteAlarms)
            }
            .navigationTitle("Alarms")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddAlarm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddAlarm) {
                WatchAddAlarmView(alarmManager: alarmManager)
            }
        }
        .onAppear {
            healthManager.requestHealthKitPermission()
        }
    }
    
    private func deleteAlarms(offsets: IndexSet) {
        for index in offsets {
            let alarm = alarmManager.alarms[index]
            alarmManager.deleteAlarm(alarm)
        }
    }
}

struct WatchAlarmRowView: View {
    let alarm: Alarm
    @ObservedObject var alarmManager: ObservableWatchAlarmManager
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(timeString)
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Text(alarm.label)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { alarm.isEnabled },
                    set: { _ in alarmManager.toggleAlarm(alarm.id) }
                ))
                .labelsHidden()
            }
            
            if !alarm.repeatDays.isEmpty {
                Text(repeatDaysString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: alarm.time)
    }
    
    private var repeatDaysString: String {
        if alarm.repeatDays.count == 7 {
            return "Every Day"
        } else {
            return alarm.repeatDays.map { $0.abbreviation }.joined(separator: " ")
        }
    }
}

#Preview {
    ContentView()
}