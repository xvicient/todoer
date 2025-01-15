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
        .package(path: "../Entities")
        
    ],
    targets: [
        .target(
            name: "ListItemsScreenContract",
            dependencies: [
                "Entities"
            ],
            path: "Contract"
        ),
        .target(
            name: "ListItemsScreen",
            dependencies: [
                "ListItemsScreenContract",
                .product(name: "Application", package: "Application"),
                .product(name: "Common", package: "Common"),
                .product(name: "ThemeComponents", package: "Theme"),
                "Data",
                "Entities"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "ListItemsScreenTests",
            dependencies: [
                "ListItemsScreen",
                .product(name: "Application", package: "Application"),
                .product(name: "ApplicationTests", package: "Application"),
                "Entities",
                .product(name: "Mocks", package: "Common")
            ]
        ),
    ]
)
