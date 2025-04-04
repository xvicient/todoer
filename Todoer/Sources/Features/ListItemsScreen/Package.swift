// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ListItemsScreen",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "ListItemsScreenContract",
            targets: ["ListItemsScreenContract"]
        ),
        .library(
            name: "ListItemsScreen",
            targets: ["ListItemsScreen"]
        ),
    ],
    dependencies: [
        .package(url: "https://www.github.com/xvicient/xRedux", from: "1.0.2"),
        .package(path: "../Common"),
        .package(path: "../Theme"),
        .package(path: "../Data"),
        .package(path: "../Entities"),
        .package(path: "../Coordinator"),
        .package(path: "../Strings"),

    ],
    targets: [
        .target(
            name: "ListItemsScreenContract",
            dependencies: [
                "Entities",
                "Common",
            ],
            path: "Sources/Contract"
        ),
        .target(
            name: "ListItemsScreen",
            dependencies: [
                "ListItemsScreenContract",
                .product(name: "xRedux", package: "xRedux"),
                "Common",
                .product(name: "ThemeComponents", package: "Theme"),
                "Data",
                .product(name: "Entities", package: "Entities"),
                .product(name: "EntitiesMocks", package: "Entities"),
                .product(name: "CoordinatorMocks", package: "Coordinator"),
                "Strings",
            ],
            path: "Sources/Implementation"
        ),
        .testTarget(
            name: "ListItemsScreenTests",
            dependencies: [
                "ListItemsScreen",
                .product(name: "xRedux", package: "xRedux"),
                .product(name: "xReduxTest", package: "xRedux"),
                .product(name: "CoordinatorMocks", package: "Coordinator"),
                .product(name: "EntitiesMocks", package: "Entities"),
                .product(name: "ThemeComponents", package: "Theme"),
                "Entities",
            ]
        ),
    ]
)
