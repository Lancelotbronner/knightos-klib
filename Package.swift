// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "klib",
	products: [
		.library(name: "klib", targets: [
			"libkcli", "libkhttp",
		]),
	],
	targets: [
		.target(name: "libkcli"),
		.target(name: "libkhttp"),
	],
	cLanguageStandard: .c2x
)
