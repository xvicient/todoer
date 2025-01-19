// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AppMenu",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AppMenu",
            targets: ["AppMenu"]
        ),
        .library(
            name: "AppMenuContract",
            targets: ["AppMenuContract"]
        )
    ],
    dependencies: [
        .package(path: "../Coordinator"),
        .package(path: "../Application"),
        .package(path: "../Common"),
        .package(path: "../Theme")
        
    ],
    targets: [
        .target(
            name: "AppMenuContract",
            dependencies: [
                .product(name: "CoordinatorContract", package: "Coordinator")
            ],
            path: "Contract"
        ),
        .target(
            name: "AppMenu",
            dependencies: [
                "AppMenuContract",
                "Application",
                "Common",
                .product(name: "ThemeAssets", package: "Theme")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "AppMenuTests",
            dependencies: ["AppMenu"]
        ),
    ]
)
