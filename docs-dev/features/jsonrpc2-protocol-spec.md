# STJSON JSON-RPC 2.0 协议层规格（BDD）

## 背景
仓库需要新增 JSON-RPC 2.0 的纯协议层能力，仅覆盖模型、编解码与协议校验，不绑定 HTTP/WebSocket 传输。

## 场景 1：单请求解码成功
- Given 一个合法 JSON-RPC 2.0 请求对象
- When 调用 `JSONRPC.decodeInbound(from:)`
- Then 应解码为 `.single(Request)` 且字段值正确

## 场景 2：通知请求不需要响应
- Given 一个缺失 `id` 的合法通知请求
- When 对 `Request` 进行响应需求判断
- Then 应识别为通知并标记为不需要响应

## 场景 3：批量请求混合通知时仅处理需响应请求
- Given 一个包含通知与普通请求的 batch
- When 调用 `Inbound.requestsRequiringResponse()`
- Then 仅返回有 `id` 的请求

## 场景 4：空 batch 为非法请求
- Given 一个空数组 batch `[]`
- When 调用 `JSONRPC.decodeInbound(from:)`
- Then 应抛出 `invalidRequest(-32600)` 对应协议错误

## 场景 5：请求字段严格校验
- Given 非法 `jsonrpc`、非法 `method`、非法 `params`
- When 解码请求
- Then 应抛出协议错误并可映射到标准错误码

## 场景 6：响应结构互斥规则
- Given 一个响应对象
- When 同时缺失或同时提供 `result` 与 `error`
- Then 应判定为非法响应

## 场景 7：ID 类型与错误对象编解码
- Given `string/int/null` 三种 `id` 与标准错误对象
- When 进行编码再解码
- Then 应保持语义一致

## 场景 8：默认 coder 与全局 shared 隔离
- Given 外部修改 `JSONEncoder.shared` 的输出策略
- When 调用 JSON-RPC 默认编码入口
- Then 编码行为不应受 `shared` 影响

## 场景 9：响应缺省 `jsonrpc` 的兼容解码
- Given 一个仅包含 `id` 与 `result`（或 `error`）的响应对象，未显式提供 `jsonrpc`
- When 解码为 `JSONRPC.Response`
- Then 应按 `jsonrpc = "2.0"` 进行兼容解码并通过响应校验
- And 若显式提供 `jsonrpc` 且不为 `"2.0"`，仍应判定为非法响应
