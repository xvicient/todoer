// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Shared",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "Shared",
            targets: ["Shared"]
        ),
    ],
    dependencies: [
        .package(url: "https://www.github.com/xvicient/xRedux", .upToNextMinor(from: "1.0.4")),
        .package(path: "../../Shared/Common"),
        .package(path: "../../Shared/Theme"),
        .package(path: "../../Shared/Entities"),
        .package(path: "../../Shared/Strings"),
    ],
    targets: [
        .target(
            name: "Shared",
            dependencies: [
                .product(name: "xRedux", package: "xRedux"),
                "Common",
                .product(name: "ThemeComponents", package: "Theme"),
                .product(name: "Entities", package: "Entities"),
                "Strings",
            ],
            path: "Sources/Implementation"
        ),
        .testTarget(
            name: "SharedTests",
            dependencies: [
                "Shared",
                .product(name: "xRedux", package: "xRedux"),
                .product(name: "xReduxTest", package: "xRedux"),
                .product(name: "Entities", package: "Entities"),
                .product(name: "EntitiesMocks", package: "Entities"),
                .product(name: "ThemeComponents", package: "Theme"),
            ]
        ),
    ]
)
