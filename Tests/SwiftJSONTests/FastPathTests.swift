//  FastPathTests.swift
import XCTest
import STJSON

class FastPathTests: XCTestCase {

    var json: JSON!

    override func setUp() {
        super.setUp()
        let dict: [String: Any] = [
            "name": "Alice",
            "age": 25,
            "height": 172.5,
            "is_active": true,
            "website": "https://example.com",
            "tags": ["developer", "swift"],
            "nested": [
                "id": 999,
                "role": "admin",
                "score": 98.4,
                "validated": true
            ]
        ]
        self.json = JSON(dict)
    }

    func testFastPathString() {
        XCTAssertEqual(json.string(at: "name"), "Alice")
        XCTAssertEqual(json.string(at: "nested", "role"), "admin")
        XCTAssertEqual(json.stringValue(at: "nested", "role"), "admin")
        
        // Non-existent key
        XCTAssertNil(json.string(at: "non_existent"))
        XCTAssertEqual(json.stringValue(at: "non_existent"), "")
        
        // Type mismatch
        XCTAssertNil(json.string(at: "age"))
        XCTAssertEqual(json.stringValue(at: "age"), "")
    }

    func testFastPathInt() {
        XCTAssertEqual(json.int(at: "age"), 25)
        XCTAssertEqual(json.int(at: "nested", "id"), 999)
        XCTAssertEqual(json.intValue(at: "nested", "id"), 999)
        
        // Non-existent key
        XCTAssertNil(json.int(at: "non_existent"))
        XCTAssertEqual(json.intValue(at: "non_existent"), 0)
    }

    func testFastPathDouble() {
        XCTAssertEqual(json.double(at: "height"), 172.5)
        XCTAssertEqual(json.double(at: "nested", "score"), 98.4)
        XCTAssertEqual(json.doubleValue(at: "nested", "score"), 98.4)
        
        // Non-existent key
        XCTAssertNil(json.double(at: "non_existent"))
        XCTAssertEqual(json.doubleValue(at: "non_existent"), 0.0)
    }

    func testFastPathBool() {
        XCTAssertEqual(json.bool(at: "is_active"), true)
        XCTAssertEqual(json.bool(at: "nested", "validated"), true)
        XCTAssertEqual(json.boolValue(at: "nested", "validated"), true)
        
        // Non-existent key
        XCTAssertNil(json.bool(at: "non_existent"))
        XCTAssertEqual(json.boolValue(at: "non_existent"), false)
    }

    func testFastPathUrl() {
        XCTAssertEqual(json.url(at: "website")?.absoluteString, "https://example.com")
        XCTAssertEqual(json.urlValue(at: "website").absoluteString, "https://example.com")
        
        // Non-existent key
        XCTAssertNil(json.url(at: "non_existent"))
        XCTAssertEqual(json.urlValue(at: "non_existent").absoluteString, "http://")
    }

    func testFastPathArray() {
        let tags = json.array(at: "tags")
        XCTAssertNotNil(tags)
        XCTAssertEqual(tags?.count, 2)
        XCTAssertEqual(tags?[0].stringValue, "developer")
        XCTAssertEqual(tags?[1].stringValue, "swift")
        
        let tagsVal = json.arrayValue(at: "tags")
        XCTAssertEqual(tagsVal.count, 2)
        
        // Non-existent key
        XCTAssertNil(json.array(at: "non_existent"))
        XCTAssertEqual(json.arrayValue(at: "non_existent").count, 0)
    }

    func testFastPathDictionary() {
        let nested = json.dictionary(at: "nested")
        XCTAssertNotNil(nested)
        XCTAssertEqual(nested?.count, 4)
        XCTAssertEqual(nested?["id"]?.intValue, 999)
        XCTAssertEqual(nested?["role"]?.stringValue, "admin")
        
        let nestedVal = json.dictionaryValue(at: "nested")
        XCTAssertEqual(nestedVal.count, 4)
        
        // Non-existent key
        XCTAssertNil(json.dictionary(at: "non_existent"))
        XCTAssertEqual(json.dictionaryValue(at: "non_existent").count, 0)
    }

    func testFastPathIndexAccess() {
        XCTAssertEqual(json.string(at: "tags", 0), "developer")
        XCTAssertEqual(json.string(at: "tags", 1), "swift")
        
        // Out of bounds
        XCTAssertNil(json.string(at: "tags", 2))
        XCTAssertNil(json.string(at: "tags", -1))
    }
}
