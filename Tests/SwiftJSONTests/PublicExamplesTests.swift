import XCTest
import Foundation
import STJSON

final class PublicExamplesTests: XCTestCase {

    func testQuickStartJSONAccessExample() throws {
        let raw = #"{"name":"Lin","age":18}"#
        let json = try JSON(data: Data(raw.utf8))

        XCTAssertEqual(json["name"].stringValue, "Lin")
        XCTAssertEqual(json["age"].intValue, 18)
    }

    func testQuickStartCodableRoundTripExample() throws {
        struct User: Codable, Equatable {
            let id: Int
            let name: String
        }

        let user = User(id: 1, name: "Lin")
        let json = try user.toJSON
        let decoded: User = try json.decode(User.self)

        XCTAssertEqual(decoded, user)
        XCTAssertEqual(json.dictionaryObject?["name"] as? String, "Lin")
    }

    func testAnyCodableExample() throws {
        let raw = #"{"id":1,"name":"Alice","meta":{"score":100},"tags":["a","b"]}"#
        let data = Data(raw.utf8)
        let payload = try JSONDecoder().decode([String: AnyCodable].self, from: data)

        XCTAssertEqual(payload["id"]?.value as? Int, 1)
        XCTAssertEqual(payload["name"]?.value as? String, "Alice")
    }

    func testJSONLinesExample() throws {
        let ndjson = #"{"id":1}"# + "\n" + #"{"id":2}"#

        var ids: [Int] = []
        try JSONLines().forEachLine(from: .string(ndjson)) { json in
            ids.append(json["id"].intValue)
        }

        XCTAssertEqual(ids, [1, 2])
    }

    func testJSONRPCExamples() throws {
        let raw = #"{"jsonrpc":"2.0","method":"sum","params":[1,2],"id":1}"#
        let inbound = try JSONRPC.decodeInbound(from: Data(raw.utf8))

        guard case .single(let request) = inbound else {
            return XCTFail("expected single request")
        }
        XCTAssertEqual(request.method, "sum")
        XCTAssertEqual(request.id, .int(1))

        let response = try JSONRPC.Response(
            id: .int(1),
            result: AnyCodable(3),
            error: nil
        )
        let data = try JSONRPC.encodeResponse(response)
        let encoded = try XCTUnwrap(String(data: data, encoding: .utf8))
        XCTAssertTrue(encoded.contains(#""jsonrpc":"2.0""#))
        XCTAssertTrue(encoded.contains(#""result":3"#))
    }
}
