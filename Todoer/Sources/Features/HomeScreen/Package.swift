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
        .package(url: "https://github.com/xvicient/xRedux", from: "1.0.0"),
        .package(path: "../Common"),
        .package(path: "../Theme"),
        .package(path: "../Coordinator"),
        .package(path: "../Data"),
        .package(path: "../Entities"),
        .package(path: "../AppMenu"),
        .package(path: "../Strings")
        
    ],
    targets: [
        .target(
            name: "HomeScreenContract",
            dependencies: [
                .product(name: "CoordinatorContract", package: "Coordinator"),
                "Common"
            ],
            path: "Sources/Contract"
        ),
        .target(
            name: "HomeScreen",
            dependencies: [
                "HomeScreenContract",
                "xRedux",
                "Common",
                .product(name: "ThemeAssets", package: "Theme"),
                .product(name: "ThemeComponents", package: "Theme"),
                "Data",
                .product(name: "CoordinatorContract", package: "Coordinator"),
                .product(name: "CoordinatorMocks", package: "Coordinator"),
                "Entities",
                "AppMenu",
                "Strings"
            ],
            path: "Sources/Implementation"
        ),
        .testTarget(
            name: "HomeScreenTests",
            dependencies: ["HomeScreen"]
        ),
    ]
)
