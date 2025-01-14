// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Theme",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ThemeAssets",
            targets: ["ThemeAssets"]
        ),
        .library(
            name: "ThemeComponents",
            targets: ["ThemeComponents"]
        )
    ],
    dependencies: [
        .package(path: "../Common")
        
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ThemeAssets",
            path: "ThemeAssets",
            resources: [
                .process("Resources/Assets.xcassets"),
                .process("Resources/Colors.xcassets")
            ]
        ),
        .target(
            name: "ThemeComponents",
            dependencies: [
                "ThemeAssets",
                .product(name: "Common", package: "Common")
            ],
            path: "ThemeComponents"
        )
    ]
)
