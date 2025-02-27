// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Entities",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "Entities",
            targets: [
                "Entities"
            ]
        ),
        .library(
            name: "EntitiesMocks",
            targets: [
                "EntitiesMocks"
            ]
        ),
    ],
    dependencies: [
        .package(path: "../Common")

    ],
    targets: [
        .target(
            name: "Entities",
            dependencies: [
                "Common"
            ],
            path: "Sources/Implementation"
        ),
        .target(
            name: "EntitiesMocks",
            dependencies: [
                "Common"
            ],
            path: "Sources/Mocks"
        ),
    ]
)
