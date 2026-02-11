# Usage examples for STJSON / AnyCodable / JSONLines

This file contains short, copy-pasteable Swift snippets showing common usage patterns in this repository.

1) AnyCodable — decode to [String: AnyCodable] and access values

```swift
import AnyCodable
import Foundation

let jsonString = #"{"id": 1, "name": "Alice", "meta": {"a": 1}}"#
let data = Data(jsonString.utf8)

let decoder = JSONDecoder()
let dictionary = try decoder.decode([String: AnyCodable].self, from: data)

// Access typed values
if let id = dictionary["id"]?.value as? Int {
  print("id=\(id)")
}

// Encode back
let encoder = JSONEncoder()
let out = try encoder.encode(dictionary)
print(String(data: out, encoding: .utf8)!)
```

Notes:
- Use [String: AnyCodable] when JSON contains heterogeneous types.
- Prefer adding small model types and decoding into structs when schema is known.

2) JSONLines — decode newline-delimited JSON (ndjson)

```swift
import STJSON
import Foundation

let ndjson = #"{"id":1}"# + "\n" + #"{"id":2}"# + "\n"
let lines = try JSONLines().decode(from: .string(ndjson))

// `lines` is an array of SwiftyJSON.JSON objects
for json in lines {
  print(try json.rawData())
}

// Map to Codable model
struct Item: Codable { let id: Int }
let models: [Item] = try lines.map { json in
  let d = try json.rawData()
  return try JSONDecoder().decode(Item.self, from: d)
}
```

Notes:
- JSONLines.decode may load all objects into memory; for large streams implement an incremental reader.

2.1) JSONLines — stream with `forEachLine` (lower peak memory)

```swift
import STJSON

let ndjson = #"{"id":1}"# + "\n" + #"{"id":2}"# + "\n"
var ids: [Int] = []

try JSONLines().forEachLine(from: .string(ndjson)) { json in
  ids.append(json["id"].intValue)
}

print(ids) // [1, 2]
```

2.2) JSONLines — `Collection` view with `lines(_:)`

```swift
import STJSON
import Foundation

let ndjson = "\n" + #"{"id":1}"# + "\n\n" + #"{"id":2}"# + "\n"
let lines = JSONLines().lines(ndjson)

// Standard Collection abilities
print(lines.count) // 2
let ids = lines.compactMap { line -> Int? in
  let json = try? JSON(data: Data(line.utf8))
  return json?["id"].int
}
print(ids) // [1, 2]
```

3) SwiftyJSON <-> Codable interop

```swift
import STJSON

// Start from raw Data (network response)
let data: Data = ...
let json = try JSON(data: data)

// Convert SwiftyJSON JSON to Data and decode into a Codable model
struct User: Codable { let id: Int; let name: String }
let raw = try json.rawData()
let user = try JSONDecoder().decode(User.self, from: raw)

// Or encode a Codable model and create a SwiftyJSON value
let model = User(id: 1, name: "Jane")
let encoded = try JSONEncoder().encode(model)
let swifty = try JSON(data: encoded)
```

Common fixes & tips
- If decoding fails due to type mismatch, verify the runtime JSON structure via `json.rawString()` or print debugging output before attempting Codable decoding.
- Prefer using strong models (Codable structs) for production paths; AnyCodable is for dynamic or exploratory code paths.
- When adding tests, follow existing tests under Tests/SwiftJSONTests and Tests/AnyCodableTests for style and expectations.
- For large JSONLines input, prefer `forEachLine` or `lines(_:)` over eager `decode` to reduce temporary memory pressure.
