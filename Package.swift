// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "Redis",
    targets: [
        Target(name: "CHiredis"),
        Target(name: "Redis", dependencies: ["CHiredis"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/Zewo/Zewo.git", majorVersion: 0, minor: 15),
    ]
)
