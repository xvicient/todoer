// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Entities",
    platforms: [
        .iOS(.v17)
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
        )
    ],
    dependencies: [
        .package(path: "../Common")
        
    ],
    targets: [
        .target(
            name: "Entities",
            path: "Sources"
        ),
        .target(
            name: "EntitiesMocks",
            dependencies: [
                "Common"
            ],
            path: "Mocks"
        )
    ]
)
