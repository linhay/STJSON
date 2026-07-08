# AnyCodable

适合处理结构不固定、需要把异构 JSON 值包进 `Codable` 模型的场景。

## Smallest Example

```swift
import AnyCodable
import Foundation

let raw = #"{"id":1,"name":"Alice","meta":{"score":100}}"#
let data = Data(raw.utf8)
let dictionary = try JSONDecoder().decode([String: AnyCodable].self, from: data)

if let id = dictionary["id"]?.value as? Int {
    print(id)
}
```

## Inside A Codable Model

```swift
import AnyCodable

struct Payload: Codable {
    let metadata: [String: AnyCodable]
}
```

## When To Recommend It

- 字段集合不稳定
- 外部接口返回结构动态变化
- 需要保留 JSON 原始异构值但仍想走 `Codable`

如果 schema 稳定，优先建议普通强类型 `Codable` 模型。
