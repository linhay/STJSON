import Foundation
import STJSON

func jsonRPCInboundExample() throws {
    let raw = #"{"jsonrpc":"2.0","method":"sum","params":[1,2],"id":1}"#
    let inbound = try JSONRPC.decodeInbound(from: Data(raw.utf8))
    print(inbound)
}

func jsonRPCResponseExample() throws {
    let response = try JSONRPC.Response(
        id: .int(1),
        result: AnyCodable(3),
        error: nil
    )
    let data = try JSONRPC.encodeResponse(response)
    print(String(data: data, encoding: .utf8) ?? "")
}
