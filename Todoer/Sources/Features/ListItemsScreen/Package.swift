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
        .package(path: "../Application"),
        .package(path: "../Common"),
        .package(path: "../Theme"),
        .package(path: "../Data"),
        .package(path: "../Entities"),
        .package(path: "../Coordinator")
        
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
                .product(name: "Application", package: "Application"),
                "Common",
                .product(name: "ThemeComponents", package: "Theme"),
                "Data",
                "Entities",
                .product(name: "CoordinatorMocks", package: "Coordinator")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "ListItemsScreenTests",
            dependencies: [
                "ListItemsScreen",
                .product(name: "Application", package: "Application"),
                .product(name: "ApplicationTests", package: "Application"),
                "Entities"
            ]
        ),
    ]
)
