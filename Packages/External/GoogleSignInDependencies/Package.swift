// swift-tools-version: 6.0
import PackageDescription

let package = Package(
	name: "GoogleSignInDependencies",
	platforms: [
		.iOS(.v17)
	],
	products: [
		.library(
			name: "GoogleSignInDependencies",
			targets: ["GoogleSignInDependencies"]
		)
	],
	dependencies: [
		.package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "8.0.0")
	],
	targets: [
		.target(
			name: "GoogleSignInDependencies",
			dependencies: [
				.product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
				.product(name: "GoogleSignInSwift", package: "GoogleSignIn-iOS"),
			]
		)
	]
)
