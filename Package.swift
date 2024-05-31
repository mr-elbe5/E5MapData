// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "E5MapData",
    platforms: [.iOS(.v15), .macOS(.v14)],
    products: [
        .library(
            name: "E5MapData",
            targets: ["E5MapData"]),
    ],
    dependencies: [
        .package(
            url: "https://git.elbe5cloud.de/miro/E5Data",
            "1.0.0"..<"1.0.100"),
        .package(
            url: "https://git.elbe5cloud.de/miro/E5PhotoLib",
            from: "1.0.0"),
        .package(
            url: "https://github.com/marmelroy/Zip",
            from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "E5MapData", dependencies: ["E5Data", "E5PhotoLib", "Zip"]),
    ]
)
