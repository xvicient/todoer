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
        .package(path: "../Entities")
        
    ],
    targets: [
        .target(
            name: "Data",
            dependencies: [
                "FirebaseDependencies",
                "GoogleSignInDependencies",
                "Entities"
            ]
        )
    ]
)
