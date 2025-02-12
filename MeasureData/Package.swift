// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MeasureData",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
        .watchOS(.v11)
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
