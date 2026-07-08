# JSON-RPC 2.0 Protocol-Layer Usage

Use STJSON `JSONRPC` for request/response/batch codec and validation without transport coupling.

```swift
import STJSON

let raw = #"{"jsonrpc":"2.0","method":"sum","params":[1,2],"id":1}"#
let inbound = try JSONRPC.decodeInbound(from: Data(raw.utf8))

switch inbound {
case .single(let request):
    if request.requiresResponse {
        let response = try JSONRPC.Response(id: request.id, result: AnyCodable(3), error: nil)
        let data = try JSONRPC.encodeResponse(response)
        print(String(data: data, encoding: .utf8) ?? "")
    }
case .batch(let requests):
    let targets = requests.filter(\.requiresResponse)
    let responses = try targets.map {
        try JSONRPC.Response(id: $0.id, result: AnyCodable("ok"), error: nil)
    }
    let data = try JSONRPC.encodeResponses(responses)
    print(String(data: data, encoding: .utf8) ?? "")
}
```

Notes:
- Strict validation: `jsonrpc` must equal `"2.0"`, `params` must be object/array.
- Response must contain exactly one of `result` or `error`.
- Default codec APIs use new `JSONEncoder()` / `JSONDecoder()` instances and do not rely on mutable shared coders.
