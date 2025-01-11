// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HomeScreen",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HomeScreen",
            targets: ["HomeScreen"]),
    ],
    dependencies: [
        .package(path: "../Application"),
        .package(path: "../Common"),
        .package(path: "../Theme"),
        .package(path: "../Coordinator"),
        .package(path: "../Data"),
        .package(path: "../Entities")
        
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HomeScreen",
            dependencies: [
                "Application",
                "Common",
                .product(name: "ThemeAssets", package: "Theme"),
                .product(name: "ThemeComponents", package: "Theme"),
                "Data",
                .product(name: "CoordinatorContract", package: "Coordinator"),
                "Entities"
            ]
        ),
        .testTarget(
            name: "HomeScreenTests",
            dependencies: ["HomeScreen"]
        ),
    ]
)
