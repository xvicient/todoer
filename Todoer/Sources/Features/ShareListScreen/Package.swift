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
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/xvicient/xRedux", from: "1.0.1"),
        .package(path: "../Common"),
        .package(path: "../Theme"),
        .package(path: "../Coordinator"),
        .package(path: "../Data"),
        .package(path: "../Entities"),
        .package(path: "../Strings"),

    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        .target(
            name: "ShareListScreenContract",
            dependencies: [
                "Entities",
                .product(name: "CoordinatorContract", package: "Coordinator"),
            ],
            path: "Sources/Contract"
        ),
        .target(
            name: "ShareListScreen",
            dependencies: [
                "ShareListScreenContract",
                .product(name: "xRedux", package: "xRedux"),
                "Common",
                .product(name: "ThemeAssets", package: "Theme"),
                .product(name: "ThemeComponents", package: "Theme"),
                "Data",
                .product(name: "CoordinatorContract", package: "Coordinator"),
                .product(name: "CoordinatorMocks", package: "Coordinator"),
                "Entities",
                "Strings",
            ],
            path: "Sources/Implementation"
        ),
        .testTarget(
            name: "ShareListScreenTests",
            dependencies: [
                "ShareListScreen",
                .product(name: "xReduxTest", package: "xRedux"),
                .product(name: "CoordinatorMocks", package: "Coordinator"),
                .product(name: "EntitiesMocks", package: "Entities"),
                "Entities",
                "Data",
            ]
        ),
    ]
)
