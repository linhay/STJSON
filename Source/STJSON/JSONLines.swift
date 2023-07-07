//
//  File.swift
//
//
//  Created by linhey on 2023/6/30.
//

import Foundation

/// https://jsonlines.org/
public struct JSONLines {
    
    public init() {}
    
}

public extension JSONLines {
    
    func decode(_ string: String) throws -> [JSON] {
        try _decode(string).map({ try JSON(data: $0) })
    }
    
    func encode(_ jsons: [JSON]) throws -> Data {
        try _encode(jsons.map({ try $0.rawData() }))
    }
    
    func decode<C: Decodable>(_ string: String, encoder: JSONDecoder) throws -> [C] {
        try _decode(string).map({ try encoder.decode(C.self, from: $0) })
    }
    
    func encode(_ jsons: [any Encodable], encoder: JSONEncoder) throws -> Data {
        try _encode(try jsons.map({ try encoder.encode($0) }))
    }
    
}

private extension JSONLines {
    
    func _decode(_ string: String) throws -> [Data] {
        return string
            .components(separatedBy: .newlines)
            .filter({ !$0.isEmpty })
            .compactMap({ $0.data(using: .utf8) })
    }
    
    func _encode(_ data: [Data]) throws -> Data {
        guard let separator = "\n".data(using: .utf8) else {
            throw JSONLinesError.invalidData
        }
        return Data(data.joined(separator: separator))
    }
    
    
}

enum JSONLinesError: Error {
    case invalidData
}
