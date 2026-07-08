# STJSON Usage Reference

这是公共入口索引。先给安装方式，再按能力选最窄示例。

## Quick Routing

- 普通强类型模型：看 `codable-extensions.md`
- 异构动态 JSON：看 `anycodable.md`
- NDJSON / `.jsonl`：看 `jsonlines.md`
- JSON-RPC 2.0 协议层：看 `jsonrpc2.md`
- 既有 SwiftyJSON 项目接入：看 `interop.md`
- 接入和运行问题：看 `troubleshooting.md`
- 需要可复制的完整示例文件：看仓库 `Examples/`
- 需要直接跑示例：执行 `swift run --package-path Examples`

## Basic Import

```swift
import STJSON
```

如果只需要动态值编码解码，也可以使用：

```swift
import AnyCodable
```

## Typical Starting Point

如果用户一开始不知道该用哪一层，默认从强类型 `Codable` 路径开始，再按需要引到动态 JSON 或 JSONLines。

## Basic JSON Conversion

```swift
struct User: Codable {
    let id: Int
    let name: String
}

let user = User(id: 1, name: "Lin")
let json = try user.toJSON
let dict = json.dictionaryObject ?? [:]
let data = try JSONEncoder().encode(user)
let decoded = try JSONDecoder().decode(User.self, from: data)
```

## STJSON + SwiftyJSON Style Access

```swift
import STJSON

let raw = #"{"name":"Lin","age":18}"#
let json = try JSON(data: Data(raw.utf8))
print(json["name"].stringValue)
```

## When To Read More

- AnyCodable 动态值：`anycodable.md`
- Codable 扩展：`codable-extensions.md`
- JSONLines：`jsonlines.md`
- JSON-RPC 2.0：`jsonrpc2.md`
- SwiftyJSON 互操作：`interop.md`
- 常见排错：`troubleshooting.md`
