// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XConfigs",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "XConfigs",
            targets: ["XConfigs"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/CombineCommunity/CombineExt", .upToNextMinor(from: "1.8.0")),
        .package(url: "https://github.com/CombineCommunity/CombineCocoa", .upToNextMinor(from: "0.4.0")),
        .package(url: "https://github.com/michaelhenry/Prettier.swift", .upToNextMajor(from: "1.1.1")),
        .package(url: "https://github.com/raspu/Highlightr", from: "2.1.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
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
