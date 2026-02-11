# STJSON Codable & Dynamic JSON 功能规格（BDD）

## 背景
当前仓库除 JSONLines 外，还提供了 Codable 扩展、动态字典/数组编解码、AnyCodable 与 SwiftyJSON 互转、JSONCodableModel 协议等能力，需要补齐可回归的行为验收。

## 场景 1：自定义 decoder 参与字符串解码
- Given 一个 ISO8601 日期字符串 JSON
- When 调用 `JSONDecoder.decode(_:from:decoder:)` 并传入自定义 `dateDecodingStrategy`
- Then 应使用传入的 decoder 正确解码，而不是忽略该参数

## 场景 2：CodableActor 支持更新策略并进行编解码
- Given 一个 `CodableActor` 实例
- When 调用 `update(encoder:)` / `update(decoder:)`
- Then 新策略应被后续 `encode`/`decode` 使用

## 场景 3：Encodable / JSON / AnyCodable 互转
- Given 一个 Codable 模型与 AnyCodable 数据
- When 调用 `toJSON`、`JSON.decode(to:)`、`AnyCodable.decode(to:)`
- Then 能稳定完成类型互转并保持字段正确

## 场景 4：JSONCodableModel 协议族能力
- Given 实现 `JSONDecodableModel` 的模型
- When 使用 `init(from data:)`、`init?(from json:)`、`Array.init(from:)`
- Then 能从 JSON/Data 构建模型，且 `decodeIfPresent` 在不存在字段时返回 nil

## 场景 5：RawRepresentable + Decodable 的 JSON 解码
- Given 字符串枚举
- When 调用 `decode(from json:)` 与 `decodeIfPresent(from:)`
- Then 合法值成功，非法值抛出解码错误

## 场景 6：`Dictionary<String, Any>` / `[Any]` 的 Codable 编解码
- Given 含嵌套对象、数组、null 的动态 JSON
- When 使用 `Codable+Dict` 扩展编码和解码
- Then 应得到一致结构；遇到不支持类型应抛 `EncodingError.invalidValue`
