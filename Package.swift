// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "ccpulse",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "ccpulse",
            path: "Sources",
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "ccpulseTests",
            dependencies: ["ccpulse"],
            path: "Tests"
        )
    ]
)
