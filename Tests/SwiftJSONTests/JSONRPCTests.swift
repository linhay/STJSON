import XCTest
import Foundation
import STJSON

final class JSONRPCTests: XCTestCase {

    private func data(_ string: String) -> Data {
        Data(string.utf8)
    }

    func testDecodeSingleRequestSuccess() throws {
        let payload = #"{"jsonrpc":"2.0","method":"sum","params":[1,2],"id":1}"#

        let inbound = try JSONRPC.decodeInbound(from: data(payload))
        guard case .single(let request) = inbound else {
            return XCTFail("expected single request")
        }
        XCTAssertEqual(request.jsonrpc, "2.0")
        XCTAssertEqual(request.method, "sum")
        XCTAssertEqual(request.id, .int(1))
        guard case .array(let params)? = request.params else {
            return XCTFail("expected array params")
        }
        XCTAssertEqual(params, [AnyCodable(1), AnyCodable(2)])
    }

    func testNotificationHasNoIDAndNoResponseNeeded() throws {
        let payload = #"{"jsonrpc":"2.0","method":"notify","params":{"ok":true}}"#

        let inbound = try JSONRPC.decodeInbound(from: data(payload))
        guard case .single(let request) = inbound else {
            return XCTFail("expected single request")
        }
        XCTAssertTrue(request.isNotification)
        XCTAssertFalse(request.requiresResponse)
    }

    func testDecodeBatchRequestSuccess() throws {
        let payload = #"[{"jsonrpc":"2.0","method":"a","id":"1"},{"jsonrpc":"2.0","method":"b","id":2}]"#

        let inbound = try JSONRPC.decodeInbound(from: data(payload))
        guard case .batch(let requests) = inbound else {
            return XCTFail("expected batch request")
        }
        XCTAssertEqual(requests.count, 2)
        XCTAssertEqual(requests[0].id, .string("1"))
        XCTAssertEqual(requests[1].id, .int(2))
    }

    func testDecodeEmptyBatchThrowsInvalidRequest() {
        let payload = #"[]"#

        XCTAssertThrowsError(try JSONRPC.decodeInbound(from: data(payload))) { error in
            guard let rpcError = error as? JSONRPC.ProtocolError else {
                return XCTFail("expected protocol error")
            }
            XCTAssertEqual(rpcError.errorCode, .invalidRequest)
        }
    }

    func testRequestValidationRejectsInvalidJSONRPCVersion() {
        let payload = #"{"jsonrpc":"1.0","method":"sum","id":1}"#

        XCTAssertThrowsError(try JSONRPC.decodeInbound(from: data(payload))) { error in
            guard let rpcError = error as? JSONRPC.ProtocolError else {
                return XCTFail("expected protocol error")
            }
            XCTAssertEqual(rpcError.errorCode, .invalidRequest)
        }
    }

    func testRequestValidationRejectsReservedMethodPrefix() {
        let payload = #"{"jsonrpc":"2.0","method":"rpc.ping","id":1}"#

        XCTAssertThrowsError(try JSONRPC.decodeInbound(from: data(payload))) { error in
            guard let rpcError = error as? JSONRPC.ProtocolError else {
                return XCTFail("expected protocol error")
            }
            XCTAssertEqual(rpcError.errorCode, .invalidRequest)
        }
    }

    func testRequestValidationRejectsScalarParams() {
        let payload = #"{"jsonrpc":"2.0","method":"sum","params":1,"id":1}"#

        XCTAssertThrowsError(try JSONRPC.decodeInbound(from: data(payload))) { error in
            guard let rpcError = error as? JSONRPC.ProtocolError else {
                return XCTFail("expected protocol error")
            }
            XCTAssertEqual(rpcError.errorCode, .invalidRequest)
        }
    }

    func testResponseValidationRequiresExactlyOneOfResultOrError() {
        XCTAssertThrowsError(
            try JSONRPC.Response(
                id: .int(1),
                result: AnyCodable(1),
                error: JSONRPC.ErrorObject(code: .internalError, message: "oops")
            )
        ) { error in
            guard let rpcError = error as? JSONRPC.ProtocolError else {
                return XCTFail("expected protocol error")
            }
            XCTAssertEqual(rpcError.errorCode, .invalidRequest)
        }

        XCTAssertThrowsError(
            try JSONRPC.Response(
                id: .int(1),
                result: nil,
                error: nil
            )
        ) { error in
            guard let rpcError = error as? JSONRPC.ProtocolError else {
                return XCTFail("expected protocol error")
            }
            XCTAssertEqual(rpcError.errorCode, .invalidRequest)
        }
    }

    func testErrorObjectRoundTripWithStandardCode() throws {
        let response = try JSONRPC.Response(
            id: .int(9),
            result: nil,
            error: JSONRPC.ErrorObject(code: .methodNotFound, message: "Method not found", data: AnyCodable(["name": "sum"]))
        )

        let encoded = try JSONRPC.encodeResponse(response)
        let decoded = try JSONDecoder().decode(JSONRPC.Response.self, from: encoded)
        XCTAssertEqual(decoded.id, .int(9))
        XCTAssertNil(decoded.result)
        XCTAssertEqual(decoded.error?.code, .methodNotFound)
        XCTAssertEqual(decoded.error?.message, "Method not found")
    }

    func testResponseDecodeAllowsMissingJSONRPCField() throws {
        let payload = #"{"id":1,"result":{"ok":true}}"#
        let decoded = try JSONDecoder().decode(JSONRPC.Response.self, from: data(payload))

        XCTAssertEqual(decoded.jsonrpc, "2.0")
        XCTAssertEqual(decoded.id, .int(1))
        XCTAssertEqual(decoded.result, AnyCodable(["ok": true]))
        XCTAssertNil(decoded.error)
    }

    func testResponseValidationRejectsInvalidJSONRPCVersion() {
        let payload = #"{"jsonrpc":"1.0","id":1,"result":{"ok":true}}"#

        XCTAssertThrowsError(try JSONDecoder().decode(JSONRPC.Response.self, from: data(payload))) { error in
            guard let rpcError = error as? JSONRPC.ProtocolError else {
                return XCTFail("expected protocol error")
            }
            XCTAssertEqual(rpcError.errorCode, .invalidRequest)
        }
    }

    func testIDSupportsStringIntNullRoundTrip() throws {
        struct Box: Codable, Equatable {
            let ids: [JSONRPC.ID]
        }

        let box = Box(ids: [.string("abc"), .int(7), .null])
        let data = try JSONEncoder().encode(box)
        let decoded = try JSONDecoder().decode(Box.self, from: data)
        XCTAssertEqual(decoded, box)
    }

    func testBatchMixedNotificationFiltersResponseGeneration() throws {
        let payload = #"[{"jsonrpc":"2.0","method":"notify"},{"jsonrpc":"2.0","method":"sum","id":1}]"#

        let inbound = try JSONRPC.decodeInbound(from: data(payload))
        let requests = inbound.requestsRequiringResponse()

        XCTAssertEqual(requests.count, 1)
        XCTAssertEqual(requests.first?.id, .int(1))
        XCTAssertFalse(requests.first?.isNotification ?? true)
    }

    func testDefaultEncoderIsIndependentFromSharedEncoder() throws {
        let oldFormatting = JSONEncoder.shared.outputFormatting
        defer {
            JSONEncoder.shared.outputFormatting = oldFormatting
        }

        JSONEncoder.shared.outputFormatting = [.prettyPrinted, .sortedKeys]

        let response = try JSONRPC.Response(id: .int(1), result: AnyCodable(["b": 2, "a": 1]), error: nil)
        let encoded = try JSONRPC.encodeResponse(response)
        let string = try XCTUnwrap(String(data: encoded, encoding: .utf8))

        XCTAssertFalse(string.contains("\n"))
    }
}
