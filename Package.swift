// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SWE_Project",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(
            name: "SWE_Project",
            targets: ["SWE_Project"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SWE_Project",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources/SWE_Project"),
        .testTarget(
            name: "SWE_ProjectTests",
            dependencies: ["SWE_Project"],
            path: "Tests/SWE_ProjectTests"),
    ]
)