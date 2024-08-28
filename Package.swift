// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-dns",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(name: "DNSKit", targets: ["DNSKit"])
    ],
    dependencies: [
//        .package(url: "https://github.com/apple/swift-testing.git", from: "0.10.0")
    ],
    targets: [
        .target(
            name: "DNSKit",
            dependencies: []
        ),
        .testTarget(
            name: "DNSKitTests",
            dependencies: [
                "DNSKit",
//                .product(name: "Testing", package: "swift-testing"),
            ],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
