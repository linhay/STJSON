// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "STJSON",
    products: [
        .library(name: "STJSON", targets: ["STJSON"]),
        .library(name: "STJSONSchema", targets: ["STJSONSchema"])
    ],
    targets: [
        .target(name: "STJSON", dependencies: []),
        .target(name: "STJSONSchema", dependencies: ["STJSON"]),
        .testTarget(name: "SwiftJSONTests", dependencies: ["STJSON"]),
//        .testTarget(name: "STJSONSchemaTests", dependencies: ["STJSONSchema"])
    ],
    swiftLanguageVersions: [.v5]
)
