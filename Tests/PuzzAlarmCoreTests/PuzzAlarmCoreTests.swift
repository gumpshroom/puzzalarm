import XCTest
@testable import PuzzAlarmCore

final class PuzzAlarmCoreTests: XCTestCase {
    
    func testAlarmCreation() {
        let alarm = Alarm(
            time: Date(),
            label: "Test Alarm",
            isEnabled: true
        )
        
        XCTAssertEqual(alarm.label, "Test Alarm")
        XCTAssertTrue(alarm.isEnabled)
        XCTAssertEqual(alarm.soundName, "default")
        XCTAssertEqual(alarm.vibrationPattern, .standard)
        XCTAssertFalse(alarm.isSilentMode)
        XCTAssertFalse(alarm.isGradualWakeup)
        XCTAssertTrue(alarm.repeatDays.isEmpty)
        XCTAssertNil(alarm.puzzleType)
    }
    
    func testAlarmManagerAddAndRetrieve() {
        let manager = AlarmManager()
        let initialCount = manager.alarms.count
        
        let alarm = Alarm(label: "Test Alarm")
        manager.addAlarm(alarm)
        
        XCTAssertEqual(manager.alarms.count, initialCount + 1)
        XCTAssertTrue(manager.alarms.contains { $0.id == alarm.id })
    }
    
    func testAlarmManagerToggle() {
        let manager = AlarmManager()
        let alarm = Alarm(label: "Test Alarm", isEnabled: true)
        manager.addAlarm(alarm)
        
        manager.toggleAlarm(alarm.id)
        let updatedAlarm = manager.alarms.first { $0.id == alarm.id }
        XCTAssertFalse(updatedAlarm?.isEnabled ?? true)
        
        manager.toggleAlarm(alarm.id)
        let toggledBackAlarm = manager.alarms.first { $0.id == alarm.id }
        XCTAssertTrue(toggledBackAlarm?.isEnabled ?? false)
    }
    
    func testStatisticsRecording() {
        var stats = AlarmStatistics(alarmId: UUID())
        
        XCTAssertEqual(stats.totalTriggers, 0)
        XCTAssertEqual(stats.totalSnoozes, 0)
        XCTAssertEqual(stats.averageSnoozeCount, 0.0)
        
        stats.recordTrigger()
        XCTAssertEqual(stats.totalTriggers, 1)
        
        stats.recordSnooze()
        XCTAssertEqual(stats.totalSnoozes, 1)
        XCTAssertEqual(stats.averageSnoozeCount, 1.0)
        
        stats.recordPuzzleCompletion(time: 30.0)
        XCTAssertEqual(stats.puzzleCompletionTimes.count, 1)
        XCTAssertEqual(stats.averagePuzzleCompletionTime, 30.0)
    }
    
    func testMathProblemGeneration() {
        let easyProblem = MathProblem.generate(difficulty: .easy)
        XCTAssertTrue(easyProblem.operand1 >= 1 && easyProblem.operand1 <= 10)
        XCTAssertTrue(easyProblem.operand2 >= 1 && easyProblem.operand2 <= 10)
        
        let hardProblem = MathProblem.generate(difficulty: .hard)
        XCTAssertTrue(hardProblem.operand1 >= 1 && hardProblem.operand1 <= 50)
        XCTAssertTrue(hardProblem.operand2 >= 1 && hardProblem.operand2 <= 50)
    }
    
    func testMathPuzzleCompletion() {
        let settings = PuzzleSettings(
            mathDifficulty: .easy,
            mathProblemCount: 2,
            mathTimeLimit: 60
        )
        let puzzle = MathPuzzle(settings: settings)
        
        puzzle.start()
        XCTAssertFalse(puzzle.isCompleted)
        XCTAssertEqual(puzzle.correctAnswers, 0)
        
        // Simulate correct answers
        if let problem = puzzle.currentProblem {
            let isCorrect = puzzle.submitAnswer(problem.correctAnswer)
            XCTAssertTrue(isCorrect)
            XCTAssertEqual(puzzle.correctAnswers, 1)
        }
        
        if let problem = puzzle.currentProblem {
            let isCorrect = puzzle.submitAnswer(problem.correctAnswer)
            XCTAssertTrue(isCorrect)
            XCTAssertEqual(puzzle.correctAnswers, 2)
            XCTAssertTrue(puzzle.isCompleted)
        }
    }
    
    func testWeekdayDisplay() {
        XCTAssertEqual(Weekday.monday.fullName, "Monday")
        XCTAssertEqual(Weekday.friday.rawValue, "Fri")
    }
    
    func testVibrationPatterns() {
        XCTAssertEqual(VibrationPattern.allCases.count, 5)
        XCTAssertTrue(VibrationPattern.allCases.contains(.standard))
        XCTAssertTrue(VibrationPattern.allCases.contains(.gentle))
    }
    
    func testPuzzleTypes() {
        XCTAssertEqual(PuzzleType.allCases.count, 3)
        XCTAssertEqual(PuzzleType.math.displayName, "Math")
        XCTAssertEqual(PuzzleType.marbleMaze.displayName, "Marble Maze")
        XCTAssertEqual(PuzzleType.water.displayName, "Water")
    }
    
    func testMazeGeneration() {
        let maze = MazeGenerator.generate(size: 8)
        XCTAssertEqual(maze.count, 8)
        XCTAssertEqual(maze[0].count, 8)
        
        // Should have start and end points
        XCTAssertEqual(maze[0][0], .start)
        XCTAssertEqual(maze[7][7], .end)
    }
    
    func testWaterCupFunctionality() {
        var cup = WaterCup(waterLevel: 0.5)
        XCTAssertEqual(cup.waterLevel, 0.5)
        XCTAssertFalse(cup.isEmpty)
        XCTAssertFalse(cup.isFull)
        
        let added = cup.addWater(0.3)
        XCTAssertEqual(added, 0.3)
        XCTAssertEqual(cup.waterLevel, 0.8)
        
        let removed = cup.removeWater(0.2)
        XCTAssertEqual(removed, 0.2)
        XCTAssertEqual(cup.waterLevel, 0.6)
        
        // Test overflow protection
        cup.addWater(0.5)
        XCTAssertEqual(cup.waterLevel, 1.0)
        XCTAssertTrue(cup.isFull)
        
        // Test underflow protection
        cup.removeWater(2.0)
        XCTAssertEqual(cup.waterLevel, 0.0)
        XCTAssertTrue(cup.isEmpty)
    }
}