// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ShareListScreen",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ShareListScreenContract",
            targets: ["ShareListScreenContract"]
        ),
        .library(
            name: "ShareListScreen",
            targets: ["ShareListScreen"]
        )
    ],
    dependencies: [
        .package(path: "../Application"),
        .package(path: "../Common"),
        .package(path: "../Theme"),
        .package(path: "../Coordinator"),
        .package(path: "../Data"),
        .package(path: "../Entities"),
        .package(path: "../Strings")
        
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        .target(
            name: "ShareListScreenContract",
            dependencies: [
                "Entities",
                .product(name: "CoordinatorContract", package: "Coordinator")
            ],
            path: "Contract"
        ),
        .target(
            name: "ShareListScreen",
            dependencies: [
                "ShareListScreenContract",
                .product(name: "Application", package: "Application"),
                "Common",
                .product(name: "ThemeAssets", package: "Theme"),
                .product(name: "ThemeComponents", package: "Theme"),
                "Data",
                .product(name: "CoordinatorContract", package: "Coordinator"),
                "Entities",
                "Strings"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "ShareListScreenTests",
            dependencies: [
                "ShareListScreen",
                .product(name: "ApplicationTests", package: "Application"),
                .product(name: "CoordinatorMocks", package: "Coordinator"),
                .product(name: "EntitiesMocks", package: "Entities"),
                "Entities",
                "Data"
            ]
        ),
    ]
)
