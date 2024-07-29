// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XConfigs",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "XConfigs",
            targets: ["XConfigs"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/CombineCommunity/CombineExt", from: "1.8.1"),
        .package(url: "https://github.com/michaelhenry/CombineCocoa", from: "1.0.1"),
        .package(url: "https://github.com/michaelhenry/Prettier.swift", from: "1.1.1"),
        .package(url: "https://github.com/raspu/Highlightr", from: "2.2.1"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "XConfigs",
            dependencies: [
                .product(name: "CombineExt", package: "CombineExt"),
                .product(name: "CombineCocoa", package: "CombineCocoa"),
                .product(name: "Prettier_swift", package: "Prettier.swift"),
                .product(name: "Highlightr", package: "Highlightr"),
            ]
        ),
    ]
)
