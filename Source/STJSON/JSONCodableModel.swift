//
//  File.swift
//
//
//  Created by linhey on 2023/6/14.
//

import Foundation

public typealias JSONCodableModel = JSONDecodableModel & JSONEncodableModel

public protocol JSONDecodableModel {
    
    init(from json: JSON) throws
    
}

public protocol JSONEncodableModel {
    
    func decode() throws -> JSON

}

public extension Encodable where Self: JSONDecodableModel {
    
    func decode() throws -> JSON {
        let data = try JSONEncoder().encode(self)
        return try JSON(data: data)
    }
    
}

public extension Array where Element: JSONEncodableModel {
    
    func decode() throws -> JSON {
        return try JSON([self.map({ try $0.decode() })])
    }
    
}

public extension JSONDecodableModel {
    
    init(from data: Data) throws {
        try self.init(from: JSON(data: data))
    }
    
    init?(from json: JSON) throws {
        guard json.isExists else { return nil }
        try self.init(from: json)
    }
    
}

extension Array: JSONDecodableModel where Element: JSONDecodableModel {
    
    public init(from json: JSON) throws {
       self = try json.arrayValue.map(Element.init(from:))
    }
    
}

public extension Decodable {
    
    static func decodeIfPresent(from json: JSON) throws -> Self? {
        guard json.exists() else { return nil }
        return try decode(from: json)
    }
    
    static func decode(from json: JSON) throws -> Self {
        guard let data = json.rawString()?.data(using: .utf8) else {
            throw STJSONError.decode
        }
        return try JSONDecoder().decode(Self.self, from: data)
    }
    
}

public extension Decodable where Self: RawRepresentable, Self.RawValue == String {
    
    static func decodeIfPresent(from json: JSON) throws -> Self? {
        guard json.exists() else { return nil }
        return try decode(from: json)
    }
    
    static func decode(from json: JSON) throws -> Self {
        guard let value = Self.init(rawValue: json.stringValue) else {
            throw STJSONError.decode
        }
        return value
    }
    
}
