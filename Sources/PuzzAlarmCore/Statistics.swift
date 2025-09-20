import Foundation

/// Statistics for alarm usage and puzzle performance
public struct AlarmStatistics: Codable {
    public let alarmId: UUID
    public var totalTriggers: Int
    public var totalSnoozes: Int
    public var averageSnoozeCount: Double
    public var puzzleCompletionTimes: [TimeInterval]
    public var averagePuzzleCompletionTime: TimeInterval
    public var sleepDetectionEvents: [SleepDetectionEvent]
    public var lastTriggered: Date?
    
    public init(alarmId: UUID) {
        self.alarmId = alarmId
        self.totalTriggers = 0
        self.totalSnoozes = 0
        self.averageSnoozeCount = 0.0
        self.puzzleCompletionTimes = []
        self.averagePuzzleCompletionTime = 0.0
        self.sleepDetectionEvents = []
        self.lastTriggered = nil
    }
    
    public mutating func recordTrigger() {
        totalTriggers += 1
        lastTriggered = Date()
        updateAverageSnoozeCount()
    }
    
    public mutating func recordSnooze() {
        totalSnoozes += 1
        updateAverageSnoozeCount()
    }
    
    public mutating func recordPuzzleCompletion(time: TimeInterval) {
        puzzleCompletionTimes.append(time)
        updateAveragePuzzleCompletionTime()
    }
    
    public mutating func recordSleepDetection(event: SleepDetectionEvent) {
        sleepDetectionEvents.append(event)
    }
    
    private mutating func updateAverageSnoozeCount() {
        guard totalTriggers > 0 else { return }
        averageSnoozeCount = Double(totalSnoozes) / Double(totalTriggers)
    }
    
    private mutating func updateAveragePuzzleCompletionTime() {
        guard !puzzleCompletionTimes.isEmpty else { return }
        averagePuzzleCompletionTime = puzzleCompletionTimes.reduce(0, +) / Double(puzzleCompletionTimes.count)
    }
}

/// Sleep detection event for WatchOS
public struct SleepDetectionEvent: Codable {
    public let timestamp: Date
    public let heartRate: Double?
    public let movement: Double?
    public let fellAsleepAgain: Bool
    public let timeToFallAsleep: TimeInterval?
    
    public init(
        timestamp: Date = Date(),
        heartRate: Double? = nil,
        movement: Double? = nil,
        fellAsleepAgain: Bool = false,
        timeToFallAsleep: TimeInterval? = nil
    ) {
        self.timestamp = timestamp
        self.heartRate = heartRate
        self.movement = movement
        self.fellAsleepAgain = fellAsleepAgain
        self.timeToFallAsleep = timeToFallAsleep
    }
}

/// Global statistics across all alarms
public struct GlobalStatistics: Codable {
    public var totalAlarmsCreated: Int
    public var totalAlarmsTriggered: Int
    public var totalSnoozes: Int
    public var mostUsedPuzzleType: PuzzleType?
    public var averageWakeUpTime: Date?
    public var longestSleepStreak: Int
    public var alarmStatistics: [UUID: AlarmStatistics]
    
    public init() {
        self.totalAlarmsCreated = 0
        self.totalAlarmsTriggered = 0
        self.totalSnoozes = 0
        self.mostUsedPuzzleType = nil
        self.averageWakeUpTime = nil
        self.longestSleepStreak = 0
        self.alarmStatistics = [:]
    }
    
    public mutating func addAlarm(_ alarm: Alarm) {
        totalAlarmsCreated += 1
        alarmStatistics[alarm.id] = AlarmStatistics(alarmId: alarm.id)
    }
    
    public mutating func recordAlarmTrigger(alarmId: UUID) {
        totalAlarmsTriggered += 1
        alarmStatistics[alarmId]?.recordTrigger()
    }
    
    public mutating func recordSnooze(alarmId: UUID) {
        totalSnoozes += 1
        alarmStatistics[alarmId]?.recordSnooze()
    }
    
    public mutating func recordPuzzleCompletion(alarmId: UUID, time: TimeInterval) {
        alarmStatistics[alarmId]?.recordPuzzleCompletion(time: time)
    }
}