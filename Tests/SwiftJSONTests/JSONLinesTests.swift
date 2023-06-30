//
//  JSONLinesTests.swift
//  
//
//  Created by linhey on 2023/6/30.
//

import XCTest
import STJSON

final class JSONLinesTests: XCTestCase {

    var testData: Data!

    override func setUp() {
        super.setUp()
        if let data = NSDataAsset(name: "jsonlines", bundle: .module)?.data {
            self.testData = data
        } else {
            XCTFail("Can't find the test JSON file")
        }
    }
    
    func testExample() throws {
        guard let string = String(data: testData, encoding: .utf8) else {
            return
        }
        let jsons = try JSONLines().decode(string)
        assert(!jsons.isEmpty)
    }

}
