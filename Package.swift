// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-dns",
    platforms: [
        .macOS(.v14),
        .iOS(.v16),
    ],
    products: [
        .library(name: "DNS", targets: ["DNS"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(
            name: "DNS",
            dependencies: [
                .product(name: "Logging", package: "swift-log")
            ]
        ),
        .testTarget(
            name: "DNSTests",
            dependencies: [
                "DNS"
            ],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
