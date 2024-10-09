// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "klib",
	products: [
		.library(name: "klib2", targets: ["BinaryCodable", "Json", "HttpClient"]),
	],
	targets: [
		.target(name: "BinaryCodable"),
		.target(name: "Json"),
		.target(name: "HttpClient"),
	]
)
