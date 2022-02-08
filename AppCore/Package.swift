// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppCore",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v15)
    ],
    products: [
        .library(name: "LaceKit", targets: ["LaceKit"]),
        .library(name: "UserActivityClient", targets: ["UserActivityClient"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "DatabaseClient", targets: ["DatabaseClient"]),
        .library(name: "AppCore", targets: ["AppCore"]),
        .library(name: "PlaybackCore", targets: ["PlaybackCore"]),
        .library(name: "AppDelegate", targets: ["AppDelegate"]),
        .library(name: "AppDelegate_iOS", targets: ["AppDelegate_iOS"]),
        .library(name: "AppDelegate_macOS", targets: ["AppDelegate_macOS"]),
        .library(name: "AppTileClient", targets: ["AppTileClient"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.33.1"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "0.2.1"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "5.21.0"),
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.0.0")
    ],
    targets: [
        // MARK: Testing Targets
        .testTarget(name: "ModelsTests",dependencies: ["Models"], resources: [
                .process("Resources")
            ]
        ),
        .testTarget(name: "AppCoreTests", dependencies: ["AppCore"]),

        // MARK: Application Targets
        .target(name: "LaceKit", dependencies: ["Models"]),
        .target(name: "Models", dependencies: []),
        .target(name: "UserActivityClient", dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            "Models"
        ]),
        .target(name: "DatabaseClient", dependencies: [
            .product(name: "GRDB", package: "GRDB.swift"),
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            "Models"
        ]),
        .target(name: "AppTileClient", dependencies: [
            "Models",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        ]),
        .target(name:"PlaybackCore", dependencies: [
            "AppTileClient",
            "Models",
            "UserActivityClient",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ]),
        .target(name: "AppCore", dependencies: [
            "Models",
            "LaceKit",
            "DatabaseClient",
            "PlaybackCore",
            "AppDelegate",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ]),
        .target(name: "AppDelegate_iOS", dependencies: [
            "AppDelegate"
        ]),
        .target(name: "AppDelegate_macOS", dependencies: [
            "AppDelegate",
            .product(name: "Sparkle", package: "Sparkle")
        ]),
        .target(name: "AppDelegate", dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        ])
    ]
)
