import Foundation
import STJSON

func anyCodableDictionaryExample() throws {
    let raw = #"{"id":1,"name":"Alice","meta":{"score":100},"tags":["a","b"]}"#
    let data = Data(raw.utf8)
    let payload = try JSONDecoder().decode([String: AnyCodable].self, from: data)

    if let id = payload["id"]?.value as? Int {
        print(id)
    }
}

struct ExampleDynamicPayload: Codable {
    let metadata: [String: AnyCodable]
}

func anyCodableModelExample() throws {
    let payload = ExampleDynamicPayload(
        metadata: [
            "enabled": AnyCodable(true),
            "score": AnyCodable(100),
            "name": AnyCodable("Alice")
        ]
    )

    let data = try JSONEncoder().encode(payload)
    let decoded = try JSONDecoder().decode(ExampleDynamicPayload.self, from: data)
    print(decoded)
}
