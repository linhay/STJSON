// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "STJSON",
    products: [
        .library(name: "STJSON", targets: ["STJSON"]),
    ],
    targets: [
        .target(name: "STJSON", dependencies: []),
        .testTarget(name: "SwiftJSONTests", dependencies: ["STJSON"]),
    ],
    swiftLanguageVersions: [.v5]
)
