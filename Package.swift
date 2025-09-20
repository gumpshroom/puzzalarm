// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PuzzAlarm",
    platforms: [
        .iOS(.v16),
        .watchOS(.v9),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "PuzzAlarmCore",
            targets: ["PuzzAlarmCore"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PuzzAlarmCore",
            dependencies: [],
            path: "Sources/PuzzAlarmCore"
        ),
        .testTarget(
            name: "PuzzAlarmCoreTests",
            dependencies: ["PuzzAlarmCore"],
            path: "Tests/PuzzAlarmCoreTests"
        )
    ]
)