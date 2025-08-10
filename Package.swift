// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "Networking",
            targets: ["Networking"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-http-types.git", exact: "1.4.0")
    ],
    targets: [
        .target(
            name: "Networking",
            dependencies: [
                .product(name: "HTTPTypes", package: "swift-http-types")
            ]
        ),
        .testTarget(
            name: "NetworkingTests",
            dependencies: ["Networking"]
        ),
    ]
)
