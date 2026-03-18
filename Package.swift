// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "ccani",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "ccani",
            path: "Sources"
        )
    ]
)
