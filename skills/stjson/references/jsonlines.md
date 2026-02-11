# JSONLines Usage

## Decode NDJSON

```swift
import STJSON
import Foundation

let ndjson = #"{"id":1}"# + "\n" + #"{"id":2}"# + "\n"
let lines = try JSONLines().decode(from: .string(ndjson))

for json in lines {
  print(try json.rawData())
}

struct Item: Codable { let id: Int }
let models: [Item] = try lines.map { json in
  let d = try json.rawData()
  return try JSONDecoder().decode(Item.self, from: d)
}
```

## Stream decode with `forEachLine`

```swift
import STJSON

let ndjson = #"{"id":1}"# + "\n" + #"{"id":2}"# + "\n"
var ids: [Int] = []

try JSONLines().forEachLine(from: .string(ndjson)) { json in
  ids.append(json["id"].intValue)
}

print(ids) // [1, 2]
```

## Unified `Source` entry (String/Data/URL)

```swift
import STJSON
import Foundation

let ndjson = #"{"id":1}"# + "\n" + #"{"id":2}"# + "\n"
let data = Data(ndjson.utf8)
let fileURL = URL(fileURLWithPath: "/tmp/sample.jsonl")

try ndjson.write(to: fileURL, atomically: true, encoding: .utf8)

let jl = JSONLines()
let a = try jl.decode(from: .string(ndjson))
let b = try jl.decode(from: .data(data))
let c = try jl.decode(from: .url(fileURL, chunkSize: 64 * 1024))
```

Important:
- `decode(from:)` / `forEachLine(from:)` / `compactMapLines(from:)` accept `JSONLines.Source`.
- Passing `URL` directly causes:
  `Cannot convert value of type 'URL' to expected argument type 'JSONLines.Source'`.
- API shape is intentionally unified as `from: Source`.

## `Collection` view with `lines(_:)`

```swift
import STJSON
import Foundation

let ndjson = "\n" + #"{"id":1}"# + "\n\n" + #"{"id":2}"# + "\n"
let lines = JSONLines().lines(ndjson)

print(lines.count) // 2
let ids = lines.compactMap { line -> Int? in
  let json = try? JSON(data: Data(line.utf8))
  return json?["id"].int
}
print(ids) // [1, 2]
```
