import Foundation
import STJSON

func jsonLinesStringExample() throws {
    let ndjson = #"{"id":1}"# + "\n" + #"{"id":2}"#

    var ids: [Int] = []
    try JSONLines().forEachLine(from: .string(ndjson)) { json in
        ids.append(json["id"].intValue)
    }

    print(ids)
}

func jsonLinesDecodableExample(fileURL: URL) throws {
    struct Record: Codable {
        let id: Int
    }

    let source = JSONLines.Source.url(fileURL, chunkSize: 64 * 1024)
    let records: [Record] = try JSONLines().decode(from: source)
    print(records)
}

func jsonLinesAsyncExample(fileURL: URL) async throws {
    for try await line in JSONLines().asyncLines(url: fileURL) {
        let json = try JSON(data: line)
        print(json)
    }
}
