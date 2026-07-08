// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "STJSONExamples",
    platforms: [.macOS(.v12)],
    dependencies: [
        .package(name: "STJSON", path: ".."),
    ],
    targets: [
        .executableTarget(
            name: "STJSONExamples",
            dependencies: [
                .product(name: "STJSON", package: "STJSON"),
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
