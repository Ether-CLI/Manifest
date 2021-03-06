// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Manifest",
    products: [
        .library(name: "Manifest", targets: ["Manifest"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "Manifest", dependencies: ["Utilities"]),
        .target(name: "Utilities", dependencies: []),
        .testTarget(name: "ManifestTests", dependencies: ["Manifest", "Utilities"]),
    ]
)
