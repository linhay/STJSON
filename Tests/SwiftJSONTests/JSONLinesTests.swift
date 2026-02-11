//
//  JSONLinesTests.swift
//  
//
//  Created by linhey on 2023/6/30.
//

import XCTest
import STJSON
import Foundation

final class JSONLinesTests: XCTestCase {
    
    private let sampleNDJSON = #"{"id":1}"# + "\n" + #"{"id":2}"# + "\n"
    
    private func makeTempJSONLURL() -> URL {
        URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("jsonlines-\(UUID().uuidString).jsonl")
    }
    
    func testExample() throws {
        let jsons = try JSONLines().decode(from: .string(sampleNDJSON))
        XCTAssertFalse(jsons.isEmpty)
    }
    
    func testForEachLineJSON() throws {
        let ndjson = #"{"id":1}"# + "\n\n" + #"{"id":2}"# + "\n"
        var ids: [Int] = []
        
        try JSONLines().forEachLine(from: .string(ndjson)) { json in
            ids.append(json["id"].intValue)
        }
        
        XCTAssertEqual(ids, [1, 2])
    }
    
    func testForEachLineDecodable() throws {
        struct Item: Decodable {
            let id: Int
        }
        
        let ndjson = #"{"id":3}"# + "\n" + #"{"id":4}"# + "\n"
        var ids: [Int] = []
        
        try JSONLines().forEachLine(from: .string(ndjson), decoder: JSONDecoder()) { (item: Item) in
            ids.append(item.id)
        }
        
        XCTAssertEqual(ids, [3, 4])
    }
    
    func testLineCollectionConformance() {
        let ndjson = "\n" + #"{"id":1}"# + "\n\n" + #"{"id":2}"# + "\n"
        let lines = JSONLines().lines(ndjson)
        
        XCTAssertEqual(lines.count, 2)
        XCTAssertEqual(lines.distance(from: lines.startIndex, to: lines.endIndex), 2)
        XCTAssertEqual(String(lines[lines.startIndex]), #"{"id":1}"#)
        
        let second = lines.index(after: lines.startIndex)
        XCTAssertEqual(String(lines[second]), #"{"id":2}"#)
    }
    
    func testLineCollectionCanBeMapped() {
        let lines = JSONLines().lines(sampleNDJSON)
        let ids: [Int] = lines.compactMap { line in
            let json = try? JSON(data: Data(line.utf8))
            return json?["id"].int
        }
        
        XCTAssertEqual(ids, [1, 2])
    }
    
    func testForEachLineDataJSON() throws {
        let data = Data(sampleNDJSON.utf8)
        var ids: [Int] = []
        
        try JSONLines().forEachLine(from: .data(data)) { json in
            ids.append(json["id"].intValue)
        }
        
        XCTAssertEqual(ids, [1, 2])
    }
    
    func testForEachLineFileURLJSON() throws {
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("jsonlines-\(UUID().uuidString).jsonl")
        try sampleNDJSON.write(to: fileURL, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: fileURL) }
        
        var ids: [Int] = []
        try JSONLines().forEachLine(from: .url(fileURL)) { json in
            ids.append(json["id"].intValue)
        }
        
        XCTAssertEqual(ids, [1, 2])
    }
    
    func testAsyncLinesFromFileURLJSON() async throws {
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("jsonlines-\(UUID().uuidString).jsonl")
        try sampleNDJSON.write(to: fileURL, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: fileURL) }
        
        var ids: [Int] = []
        for try await line in JSONLines().asyncLines(url: fileURL, chunkSize: 8) {
            let json = try JSON(data: line)
            ids.append(json["id"].intValue)
        }
        
        XCTAssertEqual(ids, [1, 2])
    }
    
    func testAsyncForEachLineDecodableFromFileURL() async throws {
        struct Item: Decodable {
            let id: Int
        }
        
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("jsonlines-\(UUID().uuidString).jsonl")
        try sampleNDJSON.write(to: fileURL, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: fileURL) }
        
        var ids: [Int] = []
        try await JSONLines().forEachLineAsync(
            url: fileURL,
            chunkSize: 8,
            decoder: JSONDecoder()
        ) { (item: Item) in
            ids.append(item.id)
        }
        
        XCTAssertEqual(ids, [1, 2])
    }
    
    func testCompactMapLinesCanSkipInvalid() throws {
        let ndjson = #"{"id":1}"# + "\n" + #"{"id":"bad"}"# + "\n" + #"{"id":2}"# + "\n"
        let ids: [Int] = try JSONLines().compactMapLines(from: .string(ndjson)) { _, line in
            let json = try? JSON(data: line)
            return json?["id"].int
        }
        
        XCTAssertEqual(ids, [1, 2])
    }
    
    func testCompactMapLinesCanCollectErrors() throws {
        struct Item: Decodable {
            let id: Int
        }
        
        let ndjson = #"{"id":1}"# + "\n" + #"{"id":"oops"}"# + "\n" + #"{"id":2}"# + "\n" + #"{bad}"# + "\n"
        var badLines: [Int] = []
        
        let ids: [Int] = try JSONLines().compactMapLines(from: .string(ndjson)) { lineNumber, line in
            do {
                let item = try JSONDecoder().decode(Item.self, from: line)
                return item.id
            } catch {
                badLines.append(lineNumber)
                return nil
            }
        }
        
        XCTAssertEqual(ids, [1, 2])
        XCTAssertEqual(badLines, [2, 4])
    }
    
    func testLineCollectionSupportsCRLFAndCR() {
        let ndjson = "\r\n" + #"{"id":1}"# + "\r\n" + #"{"id":2}"# + "\r" + #"{"id":3}"# + "\n"
        let lines = JSONLines().lines(ndjson)
        let ids: [Int] = lines.compactMap { line in
            let json = try? JSON(data: Data(line.utf8))
            return json?["id"].int
        }
        
        XCTAssertEqual(ids, [1, 2, 3])
    }
    
    func testDecodeDecodableFromDataSource() throws {
        struct Item: Decodable {
            let id: Int
        }
        
        let models: [Item] = try JSONLines().decode(from: .data(Data(sampleNDJSON.utf8)))
        XCTAssertEqual(models.map(\.id), [1, 2])
    }
    
    func testDecodeDecodableFromURLSourceWithSmallChunk() throws {
        struct Item: Decodable {
            let id: Int
        }
        
        let url = makeTempJSONLURL()
        try sampleNDJSON.write(to: url, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: url) }
        
        let models: [Item] = try JSONLines().decode(from: .url(url, chunkSize: 1))
        XCTAssertEqual(models.map(\.id), [1, 2])
    }
    
    func testForEachLineStrictModeThrowsOnInvalidLine() throws {
        let ndjson = #"{"id":1}"# + "\n" + #"{bad}"# + "\n" + #"{"id":2}"# + "\n"
        var seenIDs: [Int] = []
        
        XCTAssertThrowsError(try JSONLines().forEachLine(from: .string(ndjson)) { json in
            seenIDs.append(json["id"].intValue)
        })
        
        XCTAssertEqual(seenIDs, [1])
    }
    
    func testCompactMapLineNumbersIgnoreEmptyLines() throws {
        let ndjson = "\n" + #"{"id":1}"# + "\n\n" + #"{bad}"# + "\n"
        var lineNumbers: [Int] = []
        
        _ = try JSONLines().compactMapLines(from: .string(ndjson)) { lineNumber, line in
            lineNumbers.append(lineNumber)
            return try? JSON(data: line)
        }
        
        XCTAssertEqual(lineNumbers, [1, 2])
    }
    
    func testEncodeProducesLFSeparatedLinesWithoutTrailingLF() throws {
        let jsons: [JSON] = [try JSON(data: Data(#"{"id":1}"#.utf8)), try JSON(data: Data(#"{"id":2}"#.utf8))]
        let encoded = try JSONLines().encode(jsons)
        let text = try XCTUnwrap(String(data: encoded, encoding: .utf8))
        
        XCTAssertEqual(text, #"{"id":1}"# + "\n" + #"{"id":2}"#)
    }
    
    func testAsyncLinesReturnsLastLineWithoutTrailingNewline() async throws {
        let ndjson = #"{"id":1}"# + "\n" + #"{"id":2}"#
        let url = makeTempJSONLURL()
        try ndjson.write(to: url, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: url) }
        
        var ids: [Int] = []
        for try await line in JSONLines().asyncLines(url: url, chunkSize: 1) {
            let json = try JSON(data: line)
            ids.append(json["id"].intValue)
        }
        
        XCTAssertEqual(ids, [1, 2])
    }
    
    func testCompactMapLinesAsyncCanSkipInvalidAndCollectLineNumbers() async throws {
        let ndjson = #"{"id":1}"# + "\n" + #"{bad}"# + "\n" + #"{"id":3}"# + "\n"
        let url = makeTempJSONLURL()
        try ndjson.write(to: url, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: url) }
        
        var badLines: [Int] = []
        let ids: [Int] = try await JSONLines().compactMapLinesAsync(url: url, chunkSize: 2) { lineNumber, line in
            do {
                let json = try JSON(data: line)
                return json["id"].int
            } catch {
                badLines.append(lineNumber)
                return nil
            }
        }
        
        XCTAssertEqual(ids, [1, 3])
        XCTAssertEqual(badLines, [2])
    }

}
