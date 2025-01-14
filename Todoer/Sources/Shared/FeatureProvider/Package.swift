// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeatureProvider",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FeatureProviderContract",
            targets: ["FeatureProviderContract"]),
    ],
    dependencies: [
        .package(path: "../Entities"),
        .package(path: "../Coordinator")
        
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
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
