// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "STJSON",
    platforms: [.iOS(.v13), .macCatalyst(.v13), .macOS(.v12), .tvOS(.v12), .watchOS(.v6)],
    products: [
        .library(name: "STJSON", targets: ["STJSON"]),
    ],
    targets: [
        .target(name: "STJSON", dependencies: ["AnyCodable", "SwiftyJSON"]),
        .target(name: "AnyCodable", dependencies: []),
        .target(name: "SwiftyJSON", dependencies: []),
        .testTarget(name: "SwiftJSONTests", dependencies: ["SwiftyJSON"]),
        .testTarget(name: "AnyCodableTests", dependencies: ["AnyCodable"]),
    ],
    swiftLanguageVersions: [.v5]
)
