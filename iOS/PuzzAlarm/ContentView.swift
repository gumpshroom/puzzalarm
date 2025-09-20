import SwiftUI
import PuzzAlarmCore

struct ContentView: View {
    @StateObject private var alarmManager = ObservableAlarmManager()
    @State private var showingAddAlarm = false
    @State private var notificationPermissionGranted = false
    
    var body: some View {
        NavigationView {
            AlarmListView(alarmManager: alarmManager)
                .navigationTitle("Alarms")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
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
        // This would show the puzzle interface
        print("Alarm triggered: \(alarmId)")
    }
}

#Preview {
    ContentView()
}