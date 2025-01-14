// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Theme",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ThemeAssets",
            targets: ["ThemeAssets"]
        ),
        .library(
            name: "ThemeComponents",
            targets: ["ThemeComponents"]
        )
    ],
    dependencies: [
        .package(path: "../Common")
        
    ],
    targets: [
        .target(
            name: "ThemeAssets",
            path: "ThemeAssets",
            resources: [
                .process("Resources/Assets.xcassets"),
                .process("Resources/Colors.xcassets")
            ]
        ),
        .target(
            name: "ThemeComponents",
            dependencies: [
                "ThemeAssets",
                .product(name: "Common", package: "Common")
            ],
            path: "ThemeComponents"
        )
    ]
)
