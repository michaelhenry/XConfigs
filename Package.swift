// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XConfigs",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        .library(
            name: "XConfigs",
            targets: ["XConfigs"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift", from: "6.5.0"),
        .package(url: "https://github.com/ra1028/DiffableDataSources", from: "0.5.0"),
        .package(url: "https://github.com/michaelhenry/Prettier.swift", from: "1.1.1"),
        .package(url: "https://github.com/raspu/Highlightr", from: "2.1.2"),
    ],
    targets: [
        .target(
            name: "XConfigs",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "DiffableDataSources", package: "DiffableDataSources"),
                .product(name: "Prettier_swift", package: "Prettier.swift"),
                .product(name: "Highlightr", package: "Highlightr"),
            ]
        ),
    ]
)
