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
        .package(url: "https://github.com/xvicient/xRedux", from: "1.0.0"),
        .package(path: "../Common"),
        .package(path: "../Theme"),
        .package(path: "../Coordinator"),
        .package(path: "../Entities"),
        .package(path: "../Strings"),
        .package(path: "../../../../Packages/External/GoogleSignInDependencies")
        
    ],
    targets: [
        .target(
            name: "AuthenticationScreenContract",
            dependencies: [
                .product(name: "CoordinatorContract", package: "Coordinator")
            ],
            path: "Sources/Contract"
        ),
        .target(
            name: "AuthenticationScreen",
            dependencies: [
                "AuthenticationScreenContract",
                .product(name: "xRedux", package: "xRedux"),
                "Common",
                .product(name: "ThemeAssets", package: "Theme"),
                .product(name: "CoordinatorContract", package: "Coordinator"),
                .product(name: "CoordinatorMocks", package: "Coordinator"),
                "Entities",
                "Strings",
                "GoogleSignInDependencies"
            ],
            path: "Sources/Implementation"
        ),
        .testTarget(
            name: "AuthenticationScreenTests",
            dependencies: [
                "AuthenticationScreen",
                .product(name: "xReduxTest", package: "xRedux"),
                .product(name: "CoordinatorMocks", package: "Coordinator"),
                "Entities"
            ]
        ),
    ]
)
