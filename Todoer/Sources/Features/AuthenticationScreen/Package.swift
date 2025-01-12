// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AuthenticationScreen",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AuthenticationScreen",
            targets: ["AuthenticationScreen"]),
    ],
    dependencies: [
        .package(path: "../Application"),
        .package(path: "../Common"),
        .package(path: "../Theme"),
        .package(path: "../Coordinator"),
        .package(path: "../../../../Packages/External/GoogleSignInDependencies")
        
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AuthenticationScreen",
            dependencies: [
                .product(name: "Application", package: "Application"),
                .product(name: "Common", package: "Common"),
                .product(name: "ThemeAssets", package: "Theme"),
                .product(name: "CoordinatorContract", package: "Coordinator"),
                "GoogleSignInDependencies"
            ]
        ),
        .testTarget(
            name: "AuthenticationScreenTests",
            dependencies: [
                "AuthenticationScreen",
                .product(name: "ApplicationTests", package: "Application"),
                .product(name: "Mocks", package: "Common")
            ]
        ),
    ]
)
