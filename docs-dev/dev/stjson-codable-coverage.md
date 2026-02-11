# STJSON 非 JSONLines 能力测试与文档覆盖

关联需求：`docs-dev/features/stjson-codable-dynamicjson-spec.md`

## 覆盖目标
- 补齐 `Source/STJSON/Codable/*`、`Source/STJSON/JSONCodableModel.swift`、`Source/STJSON/AnyCodable+ext.swift` 的行为测试。
- 明确动态 JSON 编解码（`[String: Any]` / `[Any]`）的边界语义。

## 测试映射
测试文件：`Tests/SwiftJSONTests/STJSONCodableExtensionsTests.swift`

1. `testJSONDecoderDecodeFromStringUsesProvidedDecoder`
- 覆盖：`JSONDecoder.decode(_:from:decoder:)`
- 验证：调用方传入 decoder 不会被忽略（key/date strategy 生效）

2. `testCodableActorUpdateAndEncodeDecode`
- 覆盖：`CodableActor.update(encoder:)`、`update(decoder:)`、`encode/decode`
- 验证：运行期策略更新生效

3. `testEncodableToJSONAndJSONDecodeToModel`
- 覆盖：`Encodable.toJSON`、`JSON.decode(to:)`
- 验证：Codable 与 JSON 双向转换

4. `testAnyCodableDecodeAndToJSON`
- 覆盖：`AnyCodable.decode(to:)`、`AnyCodable.toJSON()`

5. `testJSONCodableModelArrayAndOptionalInit`
- 覆盖：`JSONDecodableModel` 扩展、数组模型构建、可选初始化路径

6. `testDecodableExtensionsDecodeAndDecodeIfPresent`
- 覆盖：`Decodable.decode(from:)`、`decodeIfPresent(from:)`

7. `testRawRepresentableDecodableExtension`
- 覆盖：`RawRepresentable<String> + Decodable` 的扩展解码

8. `testDynamicDictionaryArrayRoundTripWithNullAndInt`
- 覆盖：`Codable+Dict` 动态容器编码/解码
- 验证：`NSNull`、`Int`、嵌套字典/数组 round-trip 一致性

9. `testDynamicDictionaryEncodingThrowsOnUnsupportedValue`
- 覆盖：动态字典编码异常路径
- 验证：不支持类型抛 `EncodingError.invalidValue`

10. `testDynamicDecodeIfPresentMissingKeysReturnsNil`
- 覆盖：动态容器 `decodeIfPresent` 语义

## 实现修复（本次为测试驱动发现）
1. `Source/STJSON/Codable/Codable+Ext.swift`
- 修复 `JSONDecoder.decode(_:from:decoder:)` 忽略传入 decoder 的问题。

2. `Source/STJSON/Codable/Codable+Dict.swift`
- 支持 `NSNull` 编码为 JSON `null`。
- 解码时将 JSON `null` 还原为 `NSNull`。
- `[Any]` 解码优先解析 `Int`，避免整数被不必要地提升为 `Double`。

## 兼容性说明
- 对外 API 名称未变，仅修正行为一致性与边界处理。
