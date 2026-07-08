# JSON-RPC 2.0

STJSON 包含 JSON-RPC 2.0 协议层模型和编解码能力，适合：

- request / response 模型定义
- batch request / response
- protocol-level validation

说明时保持边界清晰：这是协议层，不默认绑定 HTTP / WebSocket 传输。

## Smallest Example

```swift
import STJSON

let raw = #"{"jsonrpc":"2.0","method":"sum","params":[1,2],"id":1}"#
let inbound = try JSONRPC.decodeInbound(from: Data(raw.utf8))
```

## What To Emphasize

- `jsonrpc` 必须是 `"2.0"`
- `params` 只能是 object 或 array
- response 的 `result` 和 `error` 互斥
- batch 空数组是非法请求

如果用户问的是“怎么通过 HTTP 发请求”，要明确那是传输层问题，不是这个 skill 的默认重点。
