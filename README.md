# STJSON

STJSON is a Swift package that combines:

- `SwiftyJSON`-style JSON access
- `Codable` helpers for model <-> JSON conversion
- `AnyCodable` for heterogeneous JSON payloads
- `JSONLines` / NDJSON reading and streaming
- JSON-RPC 2.0 protocol-layer models and codec

The package exports `AnyCodable` and `SwiftyJSON` through `STJSON`, so most consumers only need:

```swift
import STJSON
```

## Requirements

- Swift 5
- iOS 14+
- macOS 12+
- Mac Catalyst 13+
- tvOS 12+
- watchOS 6+

See [Package.swift](Package.swift) for the source of truth.

## Installation

### Swift Package Manager

```swift
// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "YourProject",
    dependencies: [
        .package(url: "https://github.com/linhay/STJSON.git", from: "<version>")
    ],
    targets: [
        .target(
            name: "YourTarget",
            dependencies: ["STJSON"]
        )
    ]
)
```

If you are integrating through Xcode:

1. Add `https://github.com/linhay/STJSON.git` as a package dependency.
2. Link the `STJSON` product to your target.
3. Import `STJSON` in code.

### Manual Source Integration

If you are not using Swift Package Manager, add the relevant sources from:

- `Source/STJSON/`
- `Source/AnyCodable/`
- `Source/SwiftyJSON/`

Swift Package Manager is the primary supported integration path.

For copyable examples, see [Examples/](Examples/README.md).

Run the example package from the repository root:

```sh
swift run --package-path Examples
```

## Overview

Use STJSON when you want one package that covers both dynamic JSON access and typed model workflows.

### Choose the right layer

- Stable schema: use strong `Codable` models
- Dynamic / heterogeneous values: use `AnyCodable`
- Existing `SwiftyJSON` project: keep `JSON` access and bridge into `Codable`
- NDJSON / `.jsonl`: use `JSONLines`
- JSON-RPC 2.0 protocol messages: use `JSONRPC`

## Basic Usage

### SwiftyJSON-style access

```swift
import STJSON

let raw = #"{"name":"Lin","age":18}"#
let json = try JSON(data: Data(raw.utf8))

print(json["name"].stringValue)
print(json["age"].intValue)
```

### Encode and decode a Codable model

```swift
import STJSON
import Foundation

struct User: Codable {
    let id: Int
    let name: String
}

let user = User(id: 1, name: "Lin")
let json = try user.toJSON
let decoded: User = try json.decode(User.self)
```

### Decode from a JSON string with custom decoder settings

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

### Dynamic values with AnyCodable

```swift
import STJSON
import Foundation

let raw = #"{"id":1,"name":"Alice","meta":{"score":100}}"#
let data = Data(raw.utf8)
let payload = try JSONDecoder().decode([String: AnyCodable].self, from: data)

if let id = payload["id"]?.value as? Int {
    print(id)
}
```

### JSONLines / NDJSON

```swift
import STJSON
import Foundation

let ndjson = #"{"id":1}"# + "\n" + #"{"id":2}"#

var ids: [Int] = []
try JSONLines().forEachLine(from: .string(ndjson)) { json in
    ids.append(json["id"].intValue)
}
```

For file and streaming inputs, use:

```swift
JSONLines.Source.string(ndjson)
JSONLines.Source.data(data)
JSONLines.Source.url(fileURL, chunkSize: 64 * 1024)
```

### JSON-RPC 2.0 protocol layer

```swift
import STJSON

let raw = #"{"jsonrpc":"2.0","method":"sum","params":[1,2],"id":1}"#
let inbound = try JSONRPC.decodeInbound(from: Data(raw.utf8))
```

STJSON handles protocol-layer request/response/batch models. Transport details such as HTTP or WebSocket remain outside this package.

### Bridge from SwiftyJSON into Codable

```swift
import STJSON

struct User: Codable {
    let id: Int
    let name: String
}

let json = try JSON(data: Data(#"{"id":1,"name":"Jane"}"#.utf8))
let user: User = try json.decode(to: User.self)
```

## Common Patterns

### Model -> dictionary

```swift
import STJSON

struct User: Codable {
    let id: Int
    let name: String
}

let user = User(id: 1, name: "Lin")
let json = try user.toJSON
let dict = json.dictionaryObject ?? [:]
```

### Dynamic dictionary / array inside Codable

```swift
import STJSON

struct Payload: Codable {
    let metadata: [String: Any]
    let items: [Any]
}
```

### Async JSONLines from file

```swift
import STJSON
import Foundation

for try await line in JSONLines().asyncLines(url: fileURL) {
    let json = try JSON(data: line)
    print(json)
}
```

## Troubleshooting

- `No such module 'STJSON'`:
  verify that the `STJSON` product is linked to the current target, not just added to the workspace.
- JSONLines `URL` / `Data` mismatch:
  use `JSONLines.Source.url(...)` or `JSONLines.Source.data(...)`.
- Dynamic JSON encoding fails:
  ensure values are JSON-compatible types such as `String`, `Int`, `Bool`, `[Any]`, `[String: Any]`, or `NSNull`.
- Unsure whether to use `Codable` or `AnyCodable`:
  use strong `Codable` models for stable schema, `AnyCodable` for truly dynamic payloads.

## Public Skills

This repository also maintains public usage skills under [skills/](skills/):

- [stjson-usage](skills/stjson-usage/SKILL.md)
- [stjson-update](skills/stjson-update/SKILL.md)
- [stjson-dev-feedback](skills/stjson-dev-feedback/SKILL.md)

These are the public agent-facing entry points. Repository-maintainer workflows live under [.agents/skills/](.agents/skills/README.md).

## Examples

- [Examples/Package.swift](Examples/Package.swift)
- [Examples/QuickStart.swift](Examples/QuickStart.swift)
- [Examples/AnyCodableExample.swift](Examples/AnyCodableExample.swift)
- [Examples/JSONLinesExample.swift](Examples/JSONLinesExample.swift)
- [Examples/JSONRPCExample.swift](Examples/JSONRPCExample.swift)
