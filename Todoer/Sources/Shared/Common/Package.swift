// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Common",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "Common",
            targets: ["Common"]
        )
    ],
    dependencies: [
        .package(url: "https://www.github.com/xvicient/xRedux", from: "1.0.1")
    ],
    targets: [
        .target(
            name: "Common",
            dependencies: [
                .product(name: "xRedux", package: "xRedux")
            ],
            path: "Sources/Implementation"
        )
    ]
)
