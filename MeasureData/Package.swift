// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MeasureData",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1)
    ],
    
    products: [
        .library(
            name: "MeasureData",
            type: .dynamic,
            targets: ["MeasureData"]
        )
    ],
    
    targets: [
        .target(
            name: "MeasureData",
            path: "."
        )
    ]
)
