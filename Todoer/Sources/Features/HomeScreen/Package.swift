// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HomeScreen",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "HomeScreenContract",
            targets: ["HomeScreenContract"]
        ),
        .library(
            name: "HomeScreen",
            targets: ["HomeScreen"]
        )
    ],
    dependencies: [
        .package(path: "../Application"),
        .package(path: "../Common"),
        .package(path: "../Theme"),
        .package(path: "../Coordinator"),
        .package(path: "../Data"),
        .package(path: "../Entities"),
        .package(path: "../AppMenu")
        
    ],
    targets: [
        .target(
            name: "HomeScreenContract",
            dependencies: [
                .product(name: "CoordinatorContract", package: "Coordinator"),
                "Common"
            ],
            path: "Contract"
        ),
        .target(
            name: "HomeScreen",
            dependencies: [
                "HomeScreenContract",
                "Application",
                "Common",
                .product(name: "ThemeAssets", package: "Theme"),
                .product(name: "ThemeComponents", package: "Theme"),
                "Data",
                .product(name: "CoordinatorContract", package: "Coordinator"),
                .product(name: "CoordinatorMocks", package: "Coordinator"),
                "Entities",
                "AppMenu"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "HomeScreenTests",
            dependencies: ["HomeScreen"]
        ),
    ]
)
