// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AboutScreen",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AboutScreenContract",
            targets: ["AboutScreenContract"]
        ),
        .library(
            name: "AboutScreen",
            targets: ["AboutScreen"]
        )
    ],
    dependencies: [
        .package(path: "../Common"),
        .package(path: "../Theme")
        
    ],
    targets: [
        .target(
            name: "AboutScreenContract",
            dependencies: [],
            path: "Contract"
        ),
        .target(
            name: "AboutScreen",
            dependencies: [
                "Common",
                .product(name: "ThemeAssets", package: "Theme")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "AboutScreenTests",
            dependencies: ["AboutScreen"]
        ),
    ]
)
