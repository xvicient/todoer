// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ShareListScreen",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ShareListScreen",
            targets: ["ShareListScreen"]),
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
            name: "ShareListScreen",
            dependencies: [
                .product(name: "Application", package: "Application"),
                .product(name: "Common", package: "Common"),
                .product(name: "Mocks", package: "Common"),
                .product(name: "ThemeAssets", package: "Theme"),
                .product(name: "ThemeComponents", package: "Theme"),
                "Data",
                .product(name: "CoordinatorContract", package: "Coordinator"),
                "Entities"
            ]
        ),
        .testTarget(
            name: "ShareListScreenTests",
            dependencies: [
                "ShareListScreen",
                .product(name: "ApplicationTests", package: "Application"),
                "Entities",
                "Data",
                .product(name: "Mocks", package: "Common")
            ]
        ),
    ]
)
