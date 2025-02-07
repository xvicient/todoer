// swift-tools-version: 6.0
import PackageDescription

let package = Package(
	name: "FirebaseDependencies",
	platforms: [
		.iOS(.v17)
	],
	products: [
		.library(
			name: "FirebaseDependencies",
			targets: ["FirebaseDependencies"]
		)
	],
	dependencies: [
		.package(url: "https://www.github.com/firebase/firebase-ios-sdk.git", from: "11.7.0")
	],
	targets: [
		.target(
			name: "FirebaseDependencies",
			dependencies: [
				.product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
				.product(name: "FirebaseCore", package: "firebase-ios-sdk"),
				.product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
				.product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
				.product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
			]
		)
	]
)
