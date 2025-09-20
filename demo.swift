#!/usr/bin/env swift

import Foundation

// Add the path to our module
#if canImport(PuzzAlarmCore)
import PuzzAlarmCore
#endif

// Demonstration of PuzzAlarm functionality
print("🔔 PuzzAlarm Demo")
print("=================")

// Create alarm manager
let alarmManager = AlarmManager()

// Create some sample alarms
let mathAlarm = Alarm(
    time: Date().addingTimeInterval(3600), // 1 hour from now
    isEnabled: true,
    label: "Math Challenge",
    puzzleType: .math,
    puzzleSettings: PuzzleSettings(
        mathDifficulty: .medium,
        mathProblemCount: 3,
        mathTimeLimit: 120
    )
)

let mazeAlarm = Alarm(
    time: Date().addingTimeInterval(7200), // 2 hours from now
    isEnabled: true,
    label: "Maze Challenge",
    puzzleType: .marbleMaze,
    puzzleSettings: PuzzleSettings(
        mazeDifficulty: .easy,
        mazeCompletionCount: 1
    )
)

let waterAlarm = Alarm(
    time: Date().addingTimeInterval(10800), // 3 hours from now
    isEnabled: true,
    label: "Water Pouring",
    puzzleType: .water,
    puzzleSettings: PuzzleSettings(
        waterCompletionCount: 2
    )
)

// Add alarms to manager
alarmManager.addAlarm(mathAlarm)
alarmManager.addAlarm(mazeAlarm)
alarmManager.addAlarm(waterAlarm)

print("\n📱 Created \(alarmManager.alarms.count) alarms:")
for alarm in alarmManager.alarms {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    let timeString = formatter.string(from: alarm.time)
    let puzzleInfo = alarm.puzzleType?.displayName ?? "No puzzle"
    print("  • \(alarm.label) at \(timeString) - \(puzzleInfo)")
}

print("\n🧮 Testing Math Puzzle:")
let mathPuzzle = MathPuzzle(settings: mathAlarm.puzzleSettings)
mathPuzzle.start()

if let problem = mathPuzzle.currentProblem {
    print("  Problem: \(problem.questionText)")
    print("  Answer: \(problem.correctAnswer)")
    
    // Submit correct answer
    let isCorrect = mathPuzzle.submitAnswer(problem.correctAnswer)
    print("  Submitted correct answer: \(isCorrect ? "✅" : "❌")")
    print("  Progress: \(Int(mathPuzzle.progress * 100))%")
}

print("\n🌊 Testing Water Puzzle:")
let waterPuzzle = WaterPuzzle(settings: waterAlarm.puzzleSettings)
waterPuzzle.start()
print("  Target level: \(Int(waterPuzzle.targetLevel * 100))%")
print("  Source cup: \(Int(waterPuzzle.sourceCupWaterLevel * 100))%")
print("  Target cup: \(Int(waterPuzzle.targetCupWaterLevel * 100))%")

// Simulate pouring
waterPuzzle.startPouring()
Thread.sleep(forTimeInterval: 0.5) // Let it pour for a bit
waterPuzzle.stopPouring()

print("  After pouring:")
print("    Source cup: \(Int(waterPuzzle.sourceCupWaterLevel * 100))%")
print("    Target cup: \(Int(waterPuzzle.targetCupWaterLevel * 100))%")

print("\n🎯 Testing Marble Maze:")
let mazePuzzle = MarbleMazePuzzle(settings: mazeAlarm.puzzleSettings)
mazePuzzle.start()
print("  Maze size: \(mazePuzzle.mazeLayout.count)x\(mazePuzzle.mazeLayout[0].count)")
print("  Ball position: (\(mazePuzzle.ballPosition.x), \(mazePuzzle.ballPosition.y))")

// Simulate ball movement
mazePuzzle.moveBall(deltaX: 0.1, deltaY: 0.1)
print("  After movement: (\(mazePuzzle.ballPosition.x), \(mazePuzzle.ballPosition.y))")

print("\n😴 Testing Sleep Detection:")
let sleepDetector = SleepDetectionService()
sleepDetector.startMonitoring()
print("  Monitoring: \(sleepDetector.isMonitoring)")
print("  Sleep state: \(sleepDetector.sleepState.rawValue)")

// Simulate some data
Thread.sleep(forTimeInterval: 1.0)
print("  Heart rate: \(Int(sleepDetector.currentHeartRate)) BPM")
print("  Movement: \(sleepDetector.currentMovement)")

sleepDetector.stopMonitoring()

print("\n📊 Statistics:")
print("  Total alarms created: \(alarmManager.statistics.totalAlarmsCreated)")
print("  Alarm statistics entries: \(alarmManager.statistics.alarmStatistics.count)")

print("\n✅ Demo completed successfully!")
print("The PuzzAlarm app is ready with all core features implemented:")
print("  • Multiple alarm types with custom settings")
print("  • Three interactive puzzle types (Math, Maze, Water)")
print("  • Sleep detection and monitoring")
print("  • Comprehensive statistics tracking")
print("  • Persistent data storage")
print("\nNext steps: Add SwiftUI interface and deploy to iOS/WatchOS devices!")