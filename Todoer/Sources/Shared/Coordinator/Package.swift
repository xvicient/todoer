// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Coordinator",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "CoordinatorContract",
            targets: ["CoordinatorContract"]),
        .library(
            name: "Coordinator",
            targets: ["Coordinator"])
    ],
    dependencies: [
        .package(path: "../Data"),
        .package(path: "../Entities"),
        .package(path: "../FeatureProviderContract")
        
    ],
    targets: [
        .target(
            name: "CoordinatorContract",
            dependencies: [
                "Data",
                "Entities"
            ],
            path: "Contract"
        ),
        .target(
            name: "Coordinator",
            dependencies: [
                "CoordinatorContract",
                "FeatureProviderContract"
            ],
            path: "Sources"
        ),
    ]
)
