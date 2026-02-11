# Codable Extensions Usage

## 1) `JSONDecoder.decode(_:from:decoder:)` with custom strategy

```swift
import STJSON
import Foundation

struct Event: Codable {
  let createdAt: Date
}

let raw = #"{"created_at":"2026-02-11T12:34:56Z"}"#
let decoder = JSONDecoder.new { decoder in
  decoder.keyDecodingStrategy = .convertFromSnakeCase
  decoder.dateDecodingStrategy = .iso8601
}

let event = try JSONDecoder.decode(Event.self, from: raw, decoder: decoder)
```

## 2) `CodableActor` for isolated encode/decode configuration

```swift
import STJSON
import Foundation

let actor = CodableActor()
_ = await actor.update(encoder: { encoder in
  encoder.outputFormatting = [.sortedKeys]
  encoder.dateEncodingStrategy = .iso8601
})
_ = await actor.update(decoder: { decoder in
  decoder.dateDecodingStrategy = .iso8601
})
```

## 3) Dynamic JSON with `[String: Any]` and `[Any]`

```swift
import STJSON
import Foundation

struct Payload: Codable {
  let metadata: [String: Any]
  let items: [Any]

  enum CodingKeys: String, CodingKey { case metadata, items }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let metadataContainer = try container.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: .metadata)
    metadata = try metadataContainer.decode([String: Any].self)
    var itemsContainer = try container.nestedUnkeyedContainer(forKey: .items)
    items = try itemsContainer.decode([Any].self)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    var metadataContainer = container.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: .metadata)
    try metadataContainer.encode(metadata)
    var itemsContainer = container.nestedUnkeyedContainer(forKey: .items)
    try itemsContainer.encode(items)
  }
}
```

Notes:
- `NSNull()` is encoded as `null`, and `null` is decoded back to `NSNull()`.
- Unsupported runtime values (e.g. `Date` in dynamic dict/array) throw `EncodingError.invalidValue`.
