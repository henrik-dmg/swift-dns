// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-dns",
    platforms: [
        .macOS(.v14),
        .iOS(.v16),
    ],
    products: [
        .executable(name: "dns-resolver", targets: ["dns-resolver"]),
        .library(name: "DNSKit", targets: ["DNSKit"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-async-dns-resolver",
            .upToNextMajor(from: "0.1.0")
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            .upToNextMajor(from: "1.5.0")
        ),
        .package(
            url: "https://github.com/apple/swift-log.git",
            .upToNextMajor(from: "1.0.0")
        ),
    ],
    targets: [
        .executableTarget(
            name: "dns-resolver",
            dependencies: [
                .product(name: "AsyncDNSResolver", package: "swift-async-dns-resolver"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "DNSKit",
            ]
        ),
        .target(
            name: "DNSKit",
            dependencies: [
                .product(name: "Logging", package: "swift-log")
            ]
        ),
        .testTarget(
            name: "DNSKitTests",
            dependencies: [
                "DNSKit"
            ],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
