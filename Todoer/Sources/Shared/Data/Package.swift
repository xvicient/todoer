// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Data",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Data",
            targets: [
                "Data"
            ]
        ),
        .library(
            name: "DataMocks",
            targets: [
                "DataMocks"
            ]
        )
    ],
    dependencies: [
        .package(path: "../../../../Packages/External/FirebaseDependencies"),
        .package(path: "../../../../Packages/External/GoogleSignInDependencies"),
        .package(path: "../Entities"),
        .package(path: "../Common"),
        .package(path: "../Application")
        
    ],
    targets: [
        .target(
            name: "Data",
            dependencies: [
                "FirebaseDependencies",
                "GoogleSignInDependencies",
                .product(name: "Entities", package: "Entities"),
                "Common"
            ],
            path: "Sources"
        ),
        .target(
            name: "DataMocks",
            dependencies: [
                "Entities",
                "FirebaseDependencies",
                "Data",
                .product(name: "Application", package: "Application")
            ],
            path: "Mocks"
        ),
        .testTarget(
            name: "DataTests",
            dependencies: [
                "DataMocks",
                "FirebaseDependencies",
                "GoogleSignInDependencies",
                .product(name: "Entities", package: "Entities"),
                .product(name: "EntitiesMocks", package: "Entities"),
                .product(name: "Application", package: "Application")
            ],
            path: "Tests"
        )
    ]
)
