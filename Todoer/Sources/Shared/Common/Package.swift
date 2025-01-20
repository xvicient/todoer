// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Common",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Common",
            targets: ["Common"]
        )
    ],
    dependencies: [
        .package(path: "../Application")
    ],
    targets: [
        .target(
            name: "Common",
            dependencies: [
                .product(name: "Application", package: "Application")
            ],
            path: "Sources/Common"
        )
    ]
)
