// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Theme",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "ThemeAssets",
            targets: ["ThemeAssets"]
        ),
        .library(
            name: "ThemeComponents",
            targets: ["ThemeComponents"]
        ),
    ],
    dependencies: [
        .package(url: "https://www.github.com/xvicient/xRedux", .upToNextMinor(from: "1.0.4")),
        .package(path: "../Common"),
        .package(path: "../Strings")

    ],
    targets: [
        .target(
            name: "ThemeAssets",
            path: "Sources/ThemeAssets",
            resources: [
                .process("Assets/Assets.xcassets"),
                .process("Assets/Colors.xcassets"),
            ]
        ),
        .target(
            name: "ThemeComponents",
            dependencies: [
                .product(name: "xRedux", package: "xRedux"),
                "ThemeAssets",
                "Common",
                "Strings",
            ],
            path: "Sources/ThemeComponents"
        ),
    ]
)
