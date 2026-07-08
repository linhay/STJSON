# Interop

如果项目里已经在用 `SwiftyJSON`，但又想补 `Codable` / `AnyCodable` / JSONLines 能力，可以把 STJSON 作为补充层，而不是一次性整体迁移。

优先建议：

1. 保留已有 `SwiftyJSON` 读取路径。
2. 新增强类型模型时再接 `Codable` / `AnyCodable`。
3. 处理 NDJSON 或协议层模型时单独引入 STJSON 对应能力。

## Example

```swift
import STJSON

struct User: Codable {
    let id: Int
    let name: String
}

let json = try JSON(data: Data(#"{"id":1,"name":"Jane"}"#.utf8))
let raw = try json.rawData()
let user = try JSONDecoder().decode(User.self, from: raw)
```

这条路径适合“已有 SwiftyJSON 代码很多，但新模块想走 Codable”的项目。
