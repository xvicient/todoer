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
    dependencies: [],
    targets: [
        .target(
            name: "Common",
            path: "Sources/Common"
        )
    ]
)
