// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XTouchCA",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "ControlSurface",
            targets: ["ControlSurface"]),
        .library(
            name: "XTouchMiniMC",
            targets: ["XTouchMiniMC"]),
        .library(
            name: "MIDICombine",
            targets: ["MIDICombine"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/didactek/deft-log.git", from: "0.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ControlSurface",
            dependencies: [
                "MIDICombine",
                .product(name: "DeftLog", package: "deft-log"),
            ]),
        .target(
            name: "MIDICombine",
            dependencies: [
                .product(name: "DeftLog", package: "deft-log"),
            ]),
        .target(
            name: "XTouchMiniMC",
            dependencies: [
                "ControlSurface",
                .product(name: "DeftLog", package: "deft-log"),
            ]),
        .executableTarget(
            name: "XTouchCA",
            dependencies: ["XTouchMiniMC"]),
    ]
)
