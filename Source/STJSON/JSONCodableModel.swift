//
//  File.swift
//
//
//  Created by linhey on 2023/6/14.
//

import Foundation

typealias JSONCodableModel = JSONDecodableModel & JSONEncodableModel

public protocol JSONDecodableModel {
    
    var jsonValue: Any { get throws }
    
}

public extension JSONDecodableModel {
    
    var dictionaryValue: [String: Any] {
        get throws {
            guard let dictionary = try jsonValue as? [String: Any] else {
                throw STJSONError.decode
            }
            return dictionary
        }
    }
    
    var json: Any? { try? jsonValue }
    var dictionary: [String: Any]? { try? dictionaryValue }
    
}

public extension Encodable where Self: JSONDecodableModel {
    
    var json: Any {
        get throws {
            let data = try JSONEncoder().encode(self)
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        }
    }
    
}

public extension Array where Element: JSONDecodableModel {
    
    var jsonValue: [Any] {
        get throws {
            try self.map({ try $0.jsonValue })
        }
    }
    
}

public protocol JSONEncodableModel {
    init(from json: JSON) throws
}

public extension JSONEncodableModel {
    
    init(from data: Data) throws {
        try self.init(from: JSON(data: data))
    }
    
    init?(exist json: JSON) throws {
        guard json.isExists else { return nil }
        try self.init(from: json)
    }
    
}

extension Array: JSONEncodableModel where Element: JSONEncodableModel {
    
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
