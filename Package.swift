// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WordleHelper",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "WordleHelper", targets: ["WordleHelper"]),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Rainbow", .upToNextMajor(from: "4.0.0"))
    ],
    targets: [
        .executableTarget(
            name: "WordleHelper",
            dependencies: ["Rainbow"])
    ]
)
