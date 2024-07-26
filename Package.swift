// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-dns",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        //        .executable(name: "swift-dns-server", targets: ["DNSServer"]),
        .library(name: "DNSKit", targets: ["DNSKit"])
    ],
    dependencies: [
        //        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        //        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        //        .package(url: "https://github.com/apple/swift-testing.git", from: "0.10.0"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        //        .executableTarget(
        //            name: "DNSServer",
        //            dependencies: [
        //                .product(name: "ArgumentParser", package: "swift-argument-parser"),
        //                .product(name: "NIO", package: "swift-nio"),
        //            ]
        //        ),
        .target(
            name: "DNSKit",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms")
            ]
        ),
        .testTarget(
            name: "DNSKitTests",
            dependencies: [
                "DNSKit"
                //                .product(name: "Testing", package: "swift-testing")
            ],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
