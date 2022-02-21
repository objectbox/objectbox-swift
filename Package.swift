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
            url: "https://github.com/objectbox/objectbox-swift/releases/download/v1.7.0/ObjectBox-xcframework-1.7.0.zip",
            checksum: "fb842c0ccd86a81b0640bc2dc1eee39d36528fcfc8e0af51396a45e4af7db004"
        )
    ]
)

