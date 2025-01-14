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
        ),
        .library(
            name: "Mocks",
            targets: ["Mocks"]
        )
    ],
    dependencies: [
        .package(path: "../Entities"),
        .package(path: "../Coordinator")
    ],
    targets: [
        .target(
            name: "Common",
            path: "Sources/Common"
        ),
        .target(
            name: "Mocks",
            dependencies: [
                "Entities",
                .product(name: "CoordinatorContract", package: "Coordinator")
            ],
            path: "Sources/Mocks"
        )
    ]
)
