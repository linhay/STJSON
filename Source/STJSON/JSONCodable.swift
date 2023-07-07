//
//  File.swift
//  
//
//  Created by linhey on 2023/7/7.
//

import Foundation

public extension JSONDecoder {
    
    static var shared: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()
    
    func decode<T>(_ type: T.Type,
                   from string: String,
                   using: String.Encoding = .utf8) throws -> T where T : Decodable {
        guard let data = string.data(using: using) else {
            throw STJSONError.decode
        }
        return try decode(type, from: data)
    }
    
    static func decode<T>(_ type: T.Type,
                          from string: String,
                          using: String.Encoding = .utf8) throws -> T where T : Decodable {
        return try shared.decode(type, from: string, using: using)
    }
    
    static func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        return try shared.decode(type, from: data)
    }
    
}

public extension JSONEncoder {
    
    static var shared: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()
    
    static func encodeToJSON<T>(_ value: T) throws -> String where T : Encodable {
        let data = try shared.encode(value)
        if let str = String(data: data, encoding: .utf8) {
            return str
        } else {
            return ""
        }
    }
    
}
