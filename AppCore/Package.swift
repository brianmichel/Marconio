// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var package = Package(
    name: "AppCore",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "LaceKit", targets: ["LaceKit"]),
        .library(name: "UserActivityClient", targets: ["UserActivityClient"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "DatabaseClient", targets: ["DatabaseClient"]),
        .library(name: "AppCore", targets: ["AppCore"]),
        .library(name: "PlaybackCore", targets: ["PlaybackCore"]),
        .library(name: "AppDelegate", targets: ["AppDelegate"]),
        .library(name: "AppTileClient", targets: ["AppTileClient"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.33.1"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "0.2.1"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "5.21.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(name: "LaceKit", dependencies: ["Models"]),
        .target(name: "Models", dependencies: []),
        .testTarget(name: "ModelsTests",dependencies: ["Models"], resources: [
                .process("Resources")
            ]
        ),
        .target(name: "UserActivityClient", dependencies: [
                    .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                    "Models"
                ]
        ),
        .target(name: "DatabaseClient", dependencies: [
                    .product(name: "GRDB", package: "GRDB.swift"),
                    .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                    "Models"
                ]
        ),
        .target(name: "AppTileClient", dependencies: [
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
    ]
)

#if os(macOS)
package.dependencies.append(
    .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.0.0")
)
package.targets.append(
    .target(name: "AppDelegate", dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Sparkle", package: "Sparkle")
    ])
)
#else
package.targets.append(
    .target(name: "AppDelegate", dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ])
)
#endif
