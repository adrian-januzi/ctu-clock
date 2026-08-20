// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CTUClock",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "CTUClock",
            resources: [.copy("Resources/tick.mp3")]
        )
    ]
)
