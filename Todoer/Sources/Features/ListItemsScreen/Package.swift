// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ListItemsScreen",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ListItemsScreenContract",
            targets: ["ListItemsScreenContract"]
        ),
        .library(
            name: "ListItemsScreen",
            targets: ["ListItemsScreen"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/xvicient/xRedux", from: "1.0.0"),
        .package(path: "../Common"),
        .package(path: "../Theme"),
        .package(path: "../Data"),
        .package(path: "../Entities"),
        .package(path: "../Coordinator"),
        .package(path: "../Strings")
        
    ],
    targets: [
        .target(
            name: "ListItemsScreenContract",
            dependencies: [
                "Entities",
                "Common"
            ],
            path: "Contract"
        ),
        .target(
            name: "ListItemsScreen",
            dependencies: [
                "ListItemsScreenContract",
                .product(name: "xRedux", package: "xRedux"),
                "Common",
                .product(name: "ThemeComponents", package: "Theme"),
                "Data",
                "Entities",
                .product(name: "CoordinatorMocks", package: "Coordinator"),
                "Strings"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "ListItemsScreenTests",
            dependencies: [
                "ListItemsScreen",
                .product(name: "xRedux", package: "xRedux"),
                .product(name: "xReduxTest", package: "xRedux"),
                .product(name: "CoordinatorMocks", package: "Coordinator"),
                .product(name: "EntitiesMocks", package: "Entities"),
                "Entities"
            ]
        ),
    ]
)
