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
            targets: ["Data"]),
    ],
    dependencies: [
        .package(path: "../../../../Packages/External/FirebaseDependencies"),
        .package(path: "../../../../Packages/External/GoogleSignInDependencies"),
        .package(path: "../Entities"),
        .package(path: "../Common")
        
    ],
    targets: [
        .target(
            name: "Data",
            dependencies: [
                "FirebaseDependencies",
                "GoogleSignInDependencies",
                "Entities",
                .product(name: "Common", package: "Common")
            ]
        ),
        .testTarget(
            name: "DataTests",
            dependencies: [
                .product(name: "Mocks", package: "Common"),
                "Entities"
            ],
            path: "Tests"
        )
    ]
)
