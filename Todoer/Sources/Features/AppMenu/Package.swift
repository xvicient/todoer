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
        .package(url: "https://github.com/xvicient/xRedux", from: "1.0.0"),
        .package(path: "../Common"),
        .package(path: "../Theme"),
        .package(path: "../Strings")
        
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
                "xRedux",
                "Common",
                .product(name: "ThemeAssets", package: "Theme"),
                "Strings"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "AppMenuTests",
            dependencies: ["AppMenu"]
        ),
    ]
)
