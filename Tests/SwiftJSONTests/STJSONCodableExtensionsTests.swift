import XCTest
import Foundation
import STJSON

final class STJSONCodableExtensionsTests: XCTestCase {

    private struct ISODateBox: Codable, Equatable {
        let createdAt: Date
    }

    private struct User: Codable, Equatable {
        let id: Int
        let name: String
    }

    private struct LegacyUser: Codable, JSONCodableModel, Equatable {
        let id: Int
        let name: String

        init(id: Int, name: String) {
            self.id = id
            self.name = name
        }

        init(from json: JSON) throws {
            self.id = json["id"].intValue
            self.name = json["name"].stringValue
        }
    }

    private struct DynamicPayload: Codable {
        let metadata: [String: Any]
        let items: [Any]
        let optionalMetadata: [String: Any]?
        let optionalItems: [Any]?

        enum CodingKeys: String, CodingKey {
            case metadata
            case items
            case optionalMetadata
            case optionalItems
        }

        init(
            metadata: [String: Any],
            items: [Any],
            optionalMetadata: [String: Any]?,
            optionalItems: [Any]?
        ) {
            self.metadata = metadata
            self.items = items
            self.optionalMetadata = optionalMetadata
            self.optionalItems = optionalItems
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let metadataContainer = try container.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: .metadata)
            metadata = try metadataContainer.decode([String: Any].self)

            var itemsContainer = try container.nestedUnkeyedContainer(forKey: .items)
            items = try itemsContainer.decode([Any].self)

            optionalMetadata = try container.decodeIfPresent([String: Any].self, forKey: .optionalMetadata)
            optionalItems = try container.decodeIfPresent([Any].self, forKey: .optionalItems)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(optionalMetadata, forKey: .optionalMetadata)
            try container.encode(optionalItems, forKey: .optionalItems)

            var metadataContainer = container.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: .metadata)
            try metadataContainer.encode(metadata)

            var itemsContainer = container.nestedUnkeyedContainer(forKey: .items)
            try itemsContainer.encode(items)
        }
    }

    private enum Environment: String, Decodable {
        case prod
        case dev
    }

    private func canonicalJSONData(_ object: Any) throws -> Data {
        try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
    }

    private func canonicalJSONString(_ object: Any) throws -> String {
        let data = try canonicalJSONData(object)
        guard let string = String(data: data, encoding: .utf8) else {
            XCTFail("json to string failed")
            return ""
        }
        return string
    }

    func testJSONDecoderDecodeFromStringUsesProvidedDecoder() throws {
        let json = #"{"created_at":"2026-02-11T12:34:56Z"}"#
        let decoder = JSONDecoder.new { decoder in
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
        }

        let box = try JSONDecoder.decode(ISODateBox.self, from: json, decoder: decoder)
        let formatter = ISO8601DateFormatter()
        XCTAssertEqual(box.createdAt, formatter.date(from: "2026-02-11T12:34:56Z"))
    }

    func testCodableActorUpdateAndEncodeDecode() async throws {
        let actor = CodableActor()
        _ = await actor.update(encoder: { encoder in
            encoder.outputFormatting = [.sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
        })
        _ = await actor.update(decoder: { decoder in
            decoder.dateDecodingStrategy = .iso8601
        })

        let formatter = ISO8601DateFormatter()
        let input = ISODateBox(createdAt: try XCTUnwrap(formatter.date(from: "2026-02-11T18:30:00Z")))

        let jsonString = try await actor.encode(toJSON: input)
        let decodedData = try XCTUnwrap(try XCTUnwrap(jsonString).data(using: .utf8))
        let decoded = try await actor.decode(ISODateBox.self, from: decodedData)
        XCTAssertEqual(decoded, input)
    }

    func testEncodableToJSONAndJSONDecodeToModel() throws {
        let user = User(id: 7, name: "lin")

        let json = try user.toJSON
        XCTAssertEqual(json["id"].intValue, 7)
        XCTAssertEqual(json["name"].stringValue, "lin")

        let decoded: User = try json.decode(to: User.self)
        XCTAssertEqual(decoded, user)
    }

    func testAnyCodableDecodeAndToJSON() throws {
        let payload = AnyCodable(["id": 9, "name": "agent"])

        let user: User = try payload.decode(to: User.self)
        XCTAssertEqual(user, User(id: 9, name: "agent"))

        let json = try payload.toJSON()
        XCTAssertEqual(json["id"].intValue, 9)
        XCTAssertEqual(json["name"].stringValue, "agent")
    }

    func testJSONCodableModelArrayAndOptionalInit() throws {
        let json = JSON([["id": 1, "name": "a"], ["id": 2, "name": "b"]])
        let users = try [LegacyUser](from: json)
        XCTAssertEqual(users, [LegacyUser(id: 1, name: "a"), LegacyUser(id: 2, name: "b")])

        let userJSON = try users[0].decode()
        XCTAssertEqual(userJSON["id"].intValue, 1)
        XCTAssertEqual(userJSON["name"].stringValue, "a")

        let data = try json.rawData()
        let fromData = try [LegacyUser](from: data)
        XCTAssertEqual(fromData, users)

        let missing = JSON(["x": 1])["missing"]
        let optional: LegacyUser? = try LegacyUser(from: missing)
        XCTAssertNil(optional)
    }

    func testDecodableExtensionsDecodeAndDecodeIfPresent() throws {
        let json = JSON(["id": 42, "name": "neo"])
        let user = try User.decode(from: json)
        XCTAssertEqual(user, User(id: 42, name: "neo"))

        let none = try User.decodeIfPresent(from: json["missing"])
        XCTAssertNil(none)
    }

    func testRawRepresentableDecodableExtension() throws {
        let prod = try Environment.decode(from: JSON("prod"))
        XCTAssertEqual(prod, .prod)

        let maybeDev = try Environment.decodeIfPresent(from: JSON("dev"))
        XCTAssertEqual(maybeDev, .dev)

        XCTAssertThrowsError(try Environment.decode(from: JSON("oops")))
    }

    func testDynamicDictionaryArrayRoundTripWithNullAndInt() throws {
        var metadata: [String: Any] = [
            "enabled": true,
            "count": 2,
            "ratio": 1.5,
            "title": "demo",
            "nested": ["x": 1, "arr": [1, "two", false]] as [String: Any]
        ]
        metadata["nullValue"] = NSNull()

        let items: [Any] = [1, 2.5, "three", false, ["k": "v"], [1, "x"], NSNull()]
        let payload = DynamicPayload(metadata: metadata, items: items, optionalMetadata: nil, optionalItems: nil)

        let encoded = try JSONEncoder.shared.encode(payload)
        let decoded = try JSONDecoder.shared.decode(DynamicPayload.self, from: encoded)

        let originalObject = try JSONSerialization.jsonObject(with: encoded, options: [])
        let decodedData = try JSONEncoder.shared.encode(decoded)
        let decodedObject = try JSONSerialization.jsonObject(with: decodedData, options: [])

        XCTAssertEqual(try canonicalJSONString(originalObject), try canonicalJSONString(decodedObject))
    }

    func testDynamicDictionaryEncodingThrowsOnUnsupportedValue() {
        struct InvalidPayload: Encodable {
            let metadata: [String: Any]

            enum CodingKeys: String, CodingKey {
                case metadata
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                var metadataContainer = container.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: .metadata)
                try metadataContainer.encode(metadata)
            }
        }

        let payload = InvalidPayload(metadata: ["date": Date()])
        XCTAssertThrowsError(try JSONEncoder.shared.encode(payload))
    }

    func testDynamicDecodeIfPresentMissingKeysReturnsNil() throws {
        let raw = #"{"metadata":{"ok":true},"items":[1]}"#
        let data = Data(raw.utf8)

        let decoded = try JSONDecoder.shared.decode(DynamicPayload.self, from: data)
        XCTAssertNil(decoded.optionalMetadata)
        XCTAssertNil(decoded.optionalItems)
    }
}
