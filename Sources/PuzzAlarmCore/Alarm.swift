import Foundation

/// Represents an alarm with all its configuration options
public struct Alarm: Codable, Identifiable, Equatable {
    public let id: UUID
    public var time: Date
    public var isEnabled: Bool
    public var label: String
    public var soundName: String
    public var vibrationPattern: VibrationPattern
    public var isSilentMode: Bool
    public var isGradualWakeup: Bool
    public var repeatDays: Set<Weekday>
    public var puzzleType: PuzzleType?
    public var puzzleSettings: PuzzleSettings
    
    public init(
        id: UUID = UUID(),
        time: Date = Date(),
        isEnabled: Bool = true,
        label: String = "Alarm",
        soundName: String = "default",
        vibrationPattern: VibrationPattern = .standard,
        isSilentMode: Bool = false,
        isGradualWakeup: Bool = false,
        repeatDays: Set<Weekday> = [],
        puzzleType: PuzzleType? = nil,
        puzzleSettings: PuzzleSettings = PuzzleSettings()
    ) {
        self.id = id
        self.time = time
        self.isEnabled = isEnabled
        self.label = label
        self.soundName = soundName
        self.vibrationPattern = vibrationPattern
        self.isSilentMode = isSilentMode
        self.isGradualWakeup = isGradualWakeup
        self.repeatDays = repeatDays
        self.puzzleType = puzzleType
        self.puzzleSettings = puzzleSettings
    }
}

/// Days of the week for recurring alarms
public enum Weekday: String, CaseIterable, Codable {
    case monday = "Mon"
    case tuesday = "Tue"
    case wednesday = "Wed"
    case thursday = "Thu"
    case friday = "Fri"
    case saturday = "Sat"
    case sunday = "Sun"
    
    public var fullName: String {
        switch self {
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        case .sunday: return "Sunday"
        }
    }
    
    public var abbreviation: String {
        return self.rawValue
    }
}

/// Vibration patterns for alarms
public enum VibrationPattern: String, CaseIterable, Codable {
    case none = "None"
    case standard = "Standard"
    case gentle = "Gentle"
    case strong = "Strong"
    case custom = "Custom"
    
    public var displayName: String {
        return self.rawValue
    }
}

/// Types of puzzles available
public enum PuzzleType: String, CaseIterable, Codable {
    case math = "Math"
    case marbleMaze = "Marble Maze"
    case water = "Water"
    
    public var displayName: String {
        return self.rawValue
    }
}

/// Settings for puzzle configuration
public struct PuzzleSettings: Codable, Equatable {
    public var mathDifficulty: MathDifficulty
    public var mathProblemCount: Int
    public var mathTimeLimit: TimeInterval
    public var mazeDifficulty: MazeDifficulty
    public var mazeCompletionCount: Int
    public var waterCompletionCount: Int
    
    public init(
        mathDifficulty: MathDifficulty = .medium,
        mathProblemCount: Int = 3,
        mathTimeLimit: TimeInterval = 60,
        mazeDifficulty: MazeDifficulty = .medium,
        mazeCompletionCount: Int = 1,
        waterCompletionCount: Int = 1
    ) {
        self.mathDifficulty = mathDifficulty
        self.mathProblemCount = mathProblemCount
        self.mathTimeLimit = mathTimeLimit
        self.mazeDifficulty = mazeDifficulty
        self.mazeCompletionCount = mazeCompletionCount
        self.waterCompletionCount = waterCompletionCount
    }
}

/// Difficulty levels for math puzzles
public enum MathDifficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case expert = "Expert"
    
    public var displayName: String {
        return self.rawValue
    }
}

/// Difficulty levels for marble maze
public enum MazeDifficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case expert = "Expert"
    
    public var displayName: String {
        return self.rawValue
    }
}