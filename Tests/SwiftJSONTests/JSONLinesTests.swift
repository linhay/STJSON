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

}
