// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ListItemsScreen",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ListItemsScreen",
            targets: ["ListItemsScreen"]),
    ],
    dependencies: [
        .package(path: "../Application"),
        .package(path: "../Common"),
        .package(path: "../Theme"),
        .package(path: "../Data"),
        .package(path: "../Entities")
        
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ListItemsScreen",
            dependencies: [
                "Application",
                "Common",
                .product(name: "ThemeComponents", package: "Theme"),
                "Data",
                "Entities"
            ]
        ),
        .testTarget(
            name: "ListItemsScreenTests",
            dependencies: ["ListItemsScreen"]
        ),
    ]
)
