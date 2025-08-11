// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PuzzAlarm",
    platforms: [
        .iOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "PuzzAlarmCore",
            targets: ["PuzzAlarmCore"]
        ),
        .executable(
            name: "PuzzAlarm",
            targets: ["PuzzAlarm"]
        )
    ],
    dependencies: [
        // Add SwiftUI and Combine support
    ],
    targets: [
        .target(
            name: "PuzzAlarmCore",
            dependencies: [],
            path: "Sources/PuzzAlarmCore"
        ),
        .executableTarget(
            name: "PuzzAlarm",
            dependencies: ["PuzzAlarmCore"],
            path: "Sources/PuzzAlarm"
        ),
        .testTarget(
            name: "PuzzAlarmCoreTests",
            dependencies: ["PuzzAlarmCore"],
            path: "Tests/PuzzAlarmCoreTests"
        )
    ]
)