internal var testManifest = """
// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Ether",
    products: [
        .executable(name: "Ether", targets: ["pomPom", "GorGit", "Flute", "Ether", "banzi", "Kung-Fu"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/console.git", .exact("2.3.0")),
        .package(url: "https://github.com/vapor/json.git", .exact("2.2.1")),
        .package(url: "https://github.com/vapor/core.git", .exact("2.2.0"))
    ],
    targets: [
        .target(name: "Helpers", dependencies: ["Core", "JSON"]),
        .target(name: "Ether", dependencies: ["Helpers", "Console", "JSON"]),
        .target(name: "Executable", dependencies: ["Ether"]),
        .testTarget(name: "New", dependencies: ["Helpers", "Ether"], path: "New/", exclude: ["Deprecated"]),
    ]
)
"""
