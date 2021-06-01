// swift-tools-version:5.3
 
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
            url: "https://github.com/objectbox/objectbox-swift/releases/download/v1.6.0/ObjectBox-xcframework-spm-1.6.0.zip",
            checksum: "fef591635817fed6cd695314c0eb6fa43a8feec13da2c998034f7f6d88fe9e17"
        )
    ]
)

