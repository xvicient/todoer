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
        .package(path: "../Local/Application"),
        .package(path: "../Local/Common"),
        .package(path: "../Local/Theme"),
        .package(path: "../External/GoogleSignInDependencies")
        
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AuthenticationScreen",
            dependencies: [
                "Application",
                "Common",
                "Theme",
                "GoogleSignInDependencies"
            ]
        )
    ]
)
