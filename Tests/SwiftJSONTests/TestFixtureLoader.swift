import Foundation

enum TestFixtureLoader {
    static func data(named name: String, ext: String) -> Data? {
        if let url = Bundle.module.url(forResource: name, withExtension: ext) {
            return try? Data(contentsOf: url)
        }
        if let url = Bundle.module.url(
            forResource: name,
            withExtension: ext,
            subdirectory: "data.xcassets/\(name).dataset"
        ) {
            return try? Data(contentsOf: url)
        }
        return nil
    }
}
