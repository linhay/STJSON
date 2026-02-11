# AnyCodable Usage

Decode heterogeneous JSON into `[String: AnyCodable]` and access typed values.

```swift
import AnyCodable
import Foundation

let jsonString = #"{"id": 1, "name": "Alice", "meta": {"a": 1}}"#
let data = Data(jsonString.utf8)

let decoder = JSONDecoder()
let dictionary = try decoder.decode([String: AnyCodable].self, from: data)

if let id = dictionary["id"]?.value as? Int {
  print("id=\(id)")
}

let encoder = JSONEncoder()
let out = try encoder.encode(dictionary)
print(String(data: out, encoding: .utf8)!)
```

Notes:
- Use `[String: AnyCodable]` for heterogeneous JSON payloads.
- Prefer strong Codable models when schema is stable.
