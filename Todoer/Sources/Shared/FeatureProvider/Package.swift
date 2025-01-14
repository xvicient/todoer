// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FeatureProvider",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "FeatureProviderContract",
            targets: ["FeatureProviderContract"]),
    ],
    dependencies: [
        .package(path: "../Entities"),
        .package(path: "../Coordinator")
        
    ],
    targets: [
        .target(
            name: "FeatureProviderContract",
            dependencies: [
                "Entities",
                .product(name: "CoordinatorContract", package: "Coordinator")
            ],
            path: "Sources"
        )
    ]
)
