# STJSON JSON-RPC 2.0 测试矩阵

关联需求：`docs-dev/features/jsonrpc2-protocol-spec.md`

## 覆盖目标
- 覆盖 JSON-RPC 2.0 的请求、响应、错误对象、批量语义与通知语义。
- 覆盖协议校验边界（版本、方法名、参数类型、空 batch、响应互斥规则）。
- 验证 JSON-RPC 默认编解码不依赖可变 `JSONEncoder.shared` / `JSONDecoder.shared`。

## 测试映射
测试文件：`Tests/SwiftJSONTests/JSONRPCTests.swift`

1. `testDecodeSingleRequestSuccess`
- 覆盖：`JSONRPC.decodeInbound(from:)`、`Inbound.single`

2. `testNotificationHasNoIDAndNoResponseNeeded`
- 覆盖：`Request.isNotification`

3. `testDecodeBatchRequestSuccess`
- 覆盖：`Inbound.batch` 解码

4. `testDecodeEmptyBatchThrowsInvalidRequest`
- 覆盖：空 batch 规则与错误码映射

5. `testRequestValidationRejectsInvalidJSONRPCVersion`
- 覆盖：`jsonrpc` 版本校验

6. `testRequestValidationRejectsReservedMethodPrefix`
- 覆盖：`rpc.` 保留前缀限制

7. `testRequestValidationRejectsScalarParams`
- 覆盖：`params` 仅允许 object/array

8. `testResponseValidationRequiresExactlyOneOfResultOrError`
- 覆盖：`result`/`error` 互斥约束

9. `testErrorObjectRoundTripWithStandardCode`
- 覆盖：`ErrorObject` + 标准错误码

10. `testIDSupportsStringIntNullRoundTrip`
- 覆盖：`ID` 三种合法形态

11. `testBatchMixedNotificationFiltersResponseGeneration`
- 覆盖：`Inbound.requestsRequiringResponse()`

12. `testDefaultEncoderIsIndependentFromSharedEncoder`
- 覆盖：默认编码入口与 `JSONEncoder.shared` 隔离

13. `testResponseDecodeAllowsMissingJSONRPCField`
- 覆盖：响应解码对缺省 `jsonrpc` 的兼容行为

14. `testResponseValidationRejectsInvalidJSONRPCVersion`
- 覆盖：响应中显式 `jsonrpc` 非 `2.0` 时的协议校验

## 错误码约定
- `-32700`: Parse error
- `-32600`: Invalid Request
- `-32601`: Method not found
- `-32602`: Invalid params
- `-32603`: Internal error

业务扩展通过 `JSONRPC.ErrorCode.custom(Int)` 表示。

## 兼容性说明
- 响应解码增加缺省 `jsonrpc` 的兼容处理（缺省时视为 `"2.0"`）；请求解码与显式版本校验规则保持不变。
