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
        .package(url: "https://github.com/stephencelis/SQLite.swift", .upToNextMinor(from: "0.13.3")),
        .package(url: "https://github.com/CombineCommunity/CombineExt", .upToNextMinor(from: "1.8.0")),
        .package(url: "https://github.com/CombineCommunity/CombineCocoa", .upToNextMinor(from: "0.4.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "XConfigs",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift"),
                .product(name: "CombineExt", package: "CombineExt"),
                .product(name: "CombineCocoa", package: "CombineCocoa"),
            ]
        ),
    ]
)
