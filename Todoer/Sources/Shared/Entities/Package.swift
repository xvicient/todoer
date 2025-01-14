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
            targets: ["Entities"]),
    ],
    targets: [
        .target(
            name: "Entities"),

    ]
)
