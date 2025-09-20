import SwiftUI
import PuzzAlarmCore

struct ContentView: View {
    @StateObject private var alarmManager = ObservableAlarmManager()
    @State private var showingAddAlarm = false
    @State private var notificationPermissionGranted = false
    @State private var triggeredAlarm: Alarm? = nil
    @State private var showingPuzzle = false
    
    var body: some View {
        NavigationView {
            AlarmListView(alarmManager: alarmManager)
                .navigationTitle("Alarms")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        NavigationLink {
                            SettingsView(alarmManager: alarmManager)
                        } label: {
                            Image(systemName: "gearshape")
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingAddAlarm = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingAddAlarm) {
                    AddAlarmView(alarmManager: alarmManager)
                }
                .fullScreenCover(isPresented: $showingPuzzle) {
                    if let alarm = triggeredAlarm {
                        PuzzleInterface(
                            alarm: alarm,
                            onCompleted: {
                                // Snooze alarm
                                alarmManager.snoozeAlarm(alarm.id)
                                showingPuzzle = false
                                triggeredAlarm = nil
                            },
                            onDismiss: { completionTime in
                                // Dismiss alarm with puzzle completion time
                                alarmManager.dismissAlarm(alarm.id, puzzleCompletionTime: completionTime)
                                showingPuzzle = false
                                triggeredAlarm = nil
                            }
                        )
                    }
                }
                .onAppear {
                    requestNotificationPermission()
                    setupNotificationObservers()
                }
        }
    }
    
    private func requestNotificationPermission() {
        NotificationManager.shared.requestPermission { granted in
            notificationPermissionGranted = granted
        }
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: .alarmTriggered,
            object: nil,
            queue: .main
        ) { notification in
            if let alarmId = notification.object as? UUID {
                handleAlarmTriggered(alarmId: alarmId)
            }
        }
    }
    
    private func handleAlarmTriggered(alarmId: UUID) {
        // Find the triggered alarm and show puzzle interface
        if let alarm = alarmManager.alarms.first(where: { $0.id == alarmId }) {
            triggeredAlarm = alarm
            showingPuzzle = true
        }
    }
}

#Preview {
    ContentView()
}