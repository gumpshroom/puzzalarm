# PuzzAlarm

An innovative iOS and WatchOS alarm clock app that requires users to solve puzzles before they can turn off or snooze their alarms. Built with Swift and SwiftUI, following Apple's design principles.

## Features

### Core Alarm Features
- **Multiple Alarms**: Set unlimited custom alarms with individual settings
- **Customizable Sounds**: Choose from various alarm sounds or use silent mode
- **Vibration Patterns**: Select from different vibration patterns including gentle, standard, and strong
- **Gradual Wake-up**: Slowly increase volume and vibration intensity for a gentler awakening
- **Weekly Scheduling**: Set alarms to repeat on specific days of the week
- **Silent Mode**: Vibration-only alarms for quiet environments

### Puzzle System
To turn off or snooze an alarm, users must successfully complete one of three puzzle types:

#### 1. Math Puzzle
- Solve a configurable number of math problems
- Four difficulty levels: Easy, Medium, Hard, Expert
- Customizable time limits
- Operations include addition, subtraction, multiplication, and division

#### 2. Marble Maze
- Tilt your device to guide a ball through a maze
- Multiple difficulty levels with varying maze complexity
- Configurable number of completions required
- Physics-based movement using device accelerometer

#### 3. Water Puzzle
- Pour virtual water by tilting your device
- Reach randomly specified water levels
- Uses device motion sensors for realistic pouring physics
- WatchOS support with Digital Crown control

### WatchOS Integration
- **Sleep Detection**: Uses biometric data (heart rate, movement) to detect if user falls back asleep
- **Automatic Re-triggering**: Re-activates alarm if sleep is detected after dismissal
- **Native WatchOS Interface**: Optimized for Apple Watch interaction patterns
- **Health Integration**: Leverages HealthKit for accurate biometric monitoring

### Statistics & Analytics
- **Comprehensive Tracking**: Monitor alarm usage patterns, snooze frequency, and puzzle performance
- **Performance Metrics**: Track puzzle completion times and accuracy
- **Sleep Pattern Analysis**: Understand sleep/wake cycles and falling-back-asleep patterns
- **Historical Data**: View trends over time for personal insights

## Technical Architecture

### Core Components
- **AlarmManager**: Central coordinator for alarm scheduling and management
- **Puzzle Protocols**: Extensible system for adding new puzzle types
- **Statistics Engine**: Comprehensive data collection and analysis
- **Sleep Detection Service**: WatchOS biometric monitoring (HealthKit integration)

### Design Principles
- **Minimalist UI**: Clean, intuitive interface following Apple's Human Interface Guidelines
- **Vector Graphics**: Scalable, responsive visual elements
- **Haptic Feedback**: Thoughtful tactile feedback for enhanced user experience
- **Accessibility**: Full support for VoiceOver and other accessibility features

## Project Structure

```
PuzzAlarm/
├── Sources/
│   ├── PuzzAlarmCore/          # Core business logic and models
│   │   ├── Alarm.swift         # Alarm data models and enums
│   │   ├── AlarmManager.swift  # Alarm scheduling and management
│   │   ├── Statistics.swift    # Analytics and tracking
│   │   ├── MathPuzzle.swift    # Math puzzle implementation
│   │   ├── MarbleMazePuzzle.swift  # Maze puzzle with motion controls
│   │   ├── WaterPuzzle.swift   # Water pouring puzzle
│   │   └── SleepDetectionService.swift  # WatchOS sleep monitoring
│   └── PuzzAlarm/              # SwiftUI app interface
│       └── main.swift          # App entry point and UI components
├── Tests/
│   └── PuzzAlarmCoreTests/     # Unit tests for core functionality
└── Package.swift               # Swift Package Manager configuration
```

## Installation & Setup

### Requirements
- iOS 16.0+ / WatchOS 9.0+
- Xcode 15.0+
- Swift 5.9+

### Building the App
1. Clone the repository
2. Open the project in Xcode or use Swift Package Manager
3. Build and run on device or simulator

```bash
# Build with Swift Package Manager
swift build

# Run tests
swift test
```

### Permissions Required
- **Notifications**: For alarm scheduling and triggering
- **Motion & Fitness**: For puzzle motion controls (accelerometer)
- **Health** (WatchOS): For sleep detection using heart rate and activity data

## Usage

### Setting Up Alarms
1. Tap "Add" to create a new alarm
2. Set your desired wake-up time
3. Choose alarm sound, vibration pattern, and repeat schedule
4. Select a puzzle type and configure difficulty settings
5. Save the alarm

### Solving Puzzles
When an alarm triggers:
1. The puzzle screen appears immediately
2. Complete the required puzzle to dismiss the alarm
3. Use "Snooze" button if available (may require easier puzzle)
4. Statistics are automatically recorded

### WatchOS Sleep Detection
1. Grant Health access permissions
2. Wear your Apple Watch while sleeping
3. The app monitors heart rate and movement after alarm dismissal
4. If sleep is detected, the alarm automatically re-triggers

## Customization

### Puzzle Settings
- **Math Puzzles**: Adjust difficulty, problem count, and time limits
- **Marble Maze**: Configure maze complexity and completion requirements
- **Water Puzzle**: Set number of successful pours required

### Alarm Configuration
- **Gradual Wake-up**: Enable progressive volume/vibration increase
- **Weekly Patterns**: Set different alarms for weekdays vs weekends
- **Sound & Vibration**: Choose from built-in options or silent mode

## Privacy & Data

- **Local Storage**: All data stored locally on device using UserDefaults
- **Health Data**: Only accessed with explicit permission for sleep detection
- **No Cloud Sync**: Ensures complete privacy of sleep and usage patterns
- **Minimal Data Collection**: Only essential statistics for app functionality

## Contributing

This project follows Apple's Swift style guidelines and design principles. Key areas for contribution:
- Additional puzzle types
- Enhanced statistics and insights
- Improved accessibility features
- WatchOS-specific optimizations

## License

[Add appropriate license information]

## Support

[Add support contact information]