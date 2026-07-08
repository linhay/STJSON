import Foundation
import STJSON

struct ExampleUser: Codable {
    let id: Int
    let name: String
}

@main
struct STJSONExamples {
    static func main() async throws {
        try quickStartJSONAccess()
        try quickStartCodableRoundTrip()
        try anyCodableDictionary()
        try jsonLinesString()
        try jsonRPCInboundAndResponse()
        try await jsonLinesAsyncFile()
    }

    static func quickStartJSONAccess() throws {
        let raw = #"{"name":"Lin","age":18}"#
        let json = try JSON(data: Data(raw.utf8))

        print("json.name=\(json["name"].stringValue)")
        print("json.age=\(json["age"].intValue)")
    }

    static func quickStartCodableRoundTrip() throws {
        let user = ExampleUser(id: 1, name: "Lin")
        let json = try user.toJSON
        let decoded: ExampleUser = try json.decode(ExampleUser.self)

        print("codable.decoded=\(decoded)")
        print("codable.dictionary=\(json.dictionaryObject ?? [:])")
    }

    static func anyCodableDictionary() throws {
        let raw = #"{"id":1,"name":"Alice","meta":{"score":100},"tags":["a","b"]}"#
        let data = Data(raw.utf8)
        let payload = try JSONDecoder().decode([String: AnyCodable].self, from: data)

        print("anycodable.id=\(payload["id"]?.value ?? "nil")")
    }

    static func jsonLinesString() throws {
        let ndjson = #"{"id":1}"# + "\n" + #"{"id":2}"#

        var ids: [Int] = []
        try JSONLines().forEachLine(from: .string(ndjson)) { json in
            ids.append(json["id"].intValue)
        }

        print("jsonlines.ids=\(ids)")
    }

    static func jsonRPCInboundAndResponse() throws {
        let raw = #"{"jsonrpc":"2.0","method":"sum","params":[1,2],"id":1}"#
        let inbound = try JSONRPC.decodeInbound(from: Data(raw.utf8))
        print("jsonrpc.inbound=\(inbound)")

        let response = try JSONRPC.Response(
            id: .int(1),
            result: AnyCodable(3),
            error: nil
        )
        let data = try JSONRPC.encodeResponse(response)
        print("jsonrpc.response=\(String(data: data, encoding: .utf8) ?? "")")
    }

    static func jsonLinesAsyncFile() async throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("stjson-examples")
            .appendingPathExtension("jsonl")
        let ndjson = #"{"id":3}"# + "\n" + #"{"id":4}"#
        try ndjson.write(to: url, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: url) }

        var ids: [Int] = []
        for try await line in JSONLines().asyncLines(url: url) {
            let json = try JSON(data: line)
            ids.append(json["id"].intValue)
        }

        print("jsonlines.async.ids=\(ids)")
    }
}
