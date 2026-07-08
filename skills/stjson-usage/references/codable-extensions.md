# Codable Extensions

STJSON 提供常见 `Codable` 转换辅助能力，适合这些场景：

- model -> dictionary
- string/data -> model
- 自定义 encoder / decoder 配置
- 动态字典 / 数组的编解码桥接

## Model To Dictionary

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

## Decode With Custom Decoder

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

## Dynamic JSON In A Codable Type

```swift
import STJSON

struct Payload: Codable {
    let metadata: [String: Any]
    let items: [Any]
}
```

如果用户关心的是“如何从 JSON 走回强类型模型”，优先给这条路径；只有 schema 不稳定时才切到 `AnyCodable`。
