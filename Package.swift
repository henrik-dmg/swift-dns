// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-dns",
    platforms: [
        .macOS(.v12),
        .iOS(.v16),
    ],
    products: [
        .library(name: "DNSKit", targets: ["DNSKit"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DNSKit",
            dependencies: []
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
