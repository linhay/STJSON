import Foundation
import STJSON

struct ExampleUser: Codable {
    let id: Int
    let name: String
}

func quickStartJSONAccess() throws {
    let raw = #"{"name":"Lin","age":18}"#
    let json = try JSON(data: Data(raw.utf8))

    print(json["name"].stringValue)
    print(json["age"].intValue)
}

func quickStartCodableRoundTrip() throws {
    let user = ExampleUser(id: 1, name: "Lin")
    let json = try user.toJSON
    let decoded: ExampleUser = try json.decode(ExampleUser.self)

    print(decoded)
    print(json.dictionaryObject ?? [:])
}

func quickStartCustomDecoder() throws {
    struct Event: Codable {
        let createdAt: Date
    }

    let raw = #"{"created_at":"2026-02-11T12:34:56Z"}"#
    let decoder = JSONDecoder.new { decoder in
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
    }

    let event = try JSONDecoder.decode(Event.self, from: raw, decoder: decoder)
    print(event)
}
