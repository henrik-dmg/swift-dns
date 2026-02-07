// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-dns",
    platforms: [
        .macOS(.v14),
        .iOS(.v16),
    ],
    products: [
        .library(name: "DNS", targets: ["DNSKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
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
