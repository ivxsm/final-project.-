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
        // Add your dependencies here, for example:
        // .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SWE_Project",
            path: "Sources/SWE_Project",
            dependencies: [
                // Add your target dependencies here
            ]),
        .testTarget(
            name: "SWE_ProjectTests",
            path: "Tests/SWE_ProjectTests",
            dependencies: ["SWE_Project"]),
    ]
)
