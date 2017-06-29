// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Redis",
    dependencies: [
        .package(url: "https://github.com/Zewo/Zewo.git", .branch("swift-4")),
    ],
    targets: [
        .target(name: "CHiredis"),
        .target(name: "Redis", dependencies: ["CHiredis", "Zewo"]),
    ]
)
