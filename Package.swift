// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "E5MapData",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "E5MapData",
            targets: ["E5MapData"]),
    ],
    dependencies: [
        .package(
            url: "https://git.elbe5cloud.de/miro/E5Data",
            from: "1.0.0")
    ],
    targets: [
        .target(
            name: "E5MapData", dependencies: ["E5Data"]),
    ]
)
