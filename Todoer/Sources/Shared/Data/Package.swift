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
        ),
    ],
    dependencies: [
        .package(path: "../../../../Packages/External/FirebaseDependencies"),
        .package(path: "../../../../Packages/External/GoogleSignInDependencies"),
        .package(path: "../Entities"),
        .package(path: "../Common"),
        .package(url: "https://github.com/xvicient/xRedux", from: "1.0.1"),

    ],
    targets: [
        .target(
            name: "Data",
            dependencies: [
                "FirebaseDependencies",
                "GoogleSignInDependencies",
                .product(name: "Entities", package: "Entities"),
                "Common",
            ],
            path: "Sources/Implementation"
        ),
        .target(
            name: "DataMocks",
            dependencies: [
                "Entities",
                "FirebaseDependencies",
                "Data",
                .product(name: "xRedux", package: "xRedux"),
            ],
            path: "Sources/Mocks"
        ),
        .testTarget(
            name: "DataTests",
            dependencies: [
                "DataMocks",
                "FirebaseDependencies",
                "GoogleSignInDependencies",
                .product(name: "Entities", package: "Entities"),
                .product(name: "EntitiesMocks", package: "Entities"),
                .product(name: "xRedux", package: "xRedux"),
            ],
            path: "Tests"
        ),
    ]
)
