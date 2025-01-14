// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Application",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Application",
            targets: ["Application"]
        ),
        .library(
            name: "ApplicationTests",
            targets: ["ApplicationTests"]
        )
    ],
    dependencies: [
        .package(path: "../Data")
        
    ],
    targets: [
        .target(
            name: "Application",
            dependencies: [
                "Data"
            ],
            path: "Sources/Redux"
        ),
        .target(
            name: "ApplicationTests",
            dependencies: [
                "Application"
            ],
            path: "Sources/ReduxTests"
        )
    ]
)
