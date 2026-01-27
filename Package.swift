// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Capivv",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Capivv",
            targets: ["Capivv"]
        ),
    ],
    targets: [
        .target(
            name: "Capivv",
            dependencies: [],
            path: "Sources",
            resources: [
                .process("Capivv/Resources")
            ]
        ),
        .testTarget(
            name: "CapivvTests",
            dependencies: ["Capivv"],
            path: "Tests"
        ),
    ]
)
