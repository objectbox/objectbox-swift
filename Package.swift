// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "ObjectBox",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "ObjectBox",
            targets: ["ObjectBox"]),
    ],
    targets: [
        .binaryTarget(
            name: "ObjectBox",
            url: "https://github.com/objectbox/objectbox-swift/releases/download/v1.8.1/ObjectBox-xcframework-1.8.1.zip",
            checksum: "d4f6d9caed7ae2808b15b81b769ad48e47c78d8abb882ff6fa8938cda7cf864c"
        )
    ]
)

