// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Strings",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Strings",
            targets: ["Strings"]),
    ],
    targets: [
        .target(
            name: "Strings",
            path: "Sources/Implementation"
        )
    ]
)
