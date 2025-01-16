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
            targets: ["CoordinatorContract"]
        ),
        .library(
            name: "Coordinator",
            targets: ["Coordinator"]
        ),
        .library(
            name: "CoordinatorMocks",
            targets: ["CoordinatorMocks"]
        )
    ],
    dependencies: [
        .package(path: "../Data"),
        .package(path: "../Entities")
        
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
                "CoordinatorContract"
            ],
            path: "Sources"
        ),
        .target(
            name: "CoordinatorMocks",
            dependencies: [
                "CoordinatorContract"
            ],
            path: "Mocks"
        )
    ]
)
