// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AuthenticationScreen",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AuthenticationScreenContract",
            targets: ["AuthenticationScreenContract"]
        ),
        .library(
            name: "AuthenticationScreen",
            targets: ["AuthenticationScreen"]
        )
    ],
    dependencies: [
        .package(path: "../Application"),
        .package(path: "../Common"),
        .package(path: "../Theme"),
        .package(path: "../Coordinator"),
        .package(path: "../Entities"),
        .package(path: "../../../../Packages/External/GoogleSignInDependencies")
        
    ],
    targets: [
        .target(
            name: "AuthenticationScreenContract",
            dependencies: [
                .product(name: "CoordinatorContract", package: "Coordinator")
            ],
            path: "Contract"
        ),
        .target(
            name: "AuthenticationScreen",
            dependencies: [
                "AuthenticationScreenContract",
                .product(name: "Application", package: "Application"),
                "Common",
                .product(name: "ThemeAssets", package: "Theme"),
                .product(name: "CoordinatorContract", package: "Coordinator"),
                .product(name: "CoordinatorMocks", package: "Coordinator"),
                "Entities",
                "GoogleSignInDependencies"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "AuthenticationScreenTests",
            dependencies: [
                "AuthenticationScreen",
                .product(name: "ApplicationTests", package: "Application"),
                .product(name: "CoordinatorMocks", package: "Coordinator"),
                "Entities"
            ]
        ),
    ]
)
