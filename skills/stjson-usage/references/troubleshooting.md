# Troubleshooting

## Common Routing

- 编译时 `No such module 'STJSON'`：
  先检查依赖是否真的加到了当前 target，而不只是仓库或 workspace。
- `URL` / `Data` 不能直接传给 JSONLines 某些接口：
  改用 `JSONLines.Source.url(...)` 或 `JSONLines.Source.data(...)`。
- 动态 JSON 编码失败：
  先确认值是不是 `String` / `Int` / `Bool` / `[Any]` / `[String: Any]` 这类可桥接类型。
- 类型不匹配：
  先看原始 JSON shape，再决定是强类型 `Codable` 还是 `AnyCodable`。

## Practical Guidance

1. schema 稳定时，优先强类型 `Codable`
2. schema 不稳定时，再上 `AnyCodable`
3. 大型 `.jsonl` 输入不要默认整包 decode
4. JSON-RPC 2.0 只处理协议层，不自动帮用户定义网络层
