//
//  File.swift
//  
//
//  Created by linhey on 2023/7/7.
//

import Foundation

public extension Encodable {
    
    var toJSON: JSON {
        get throws {
            let data = try JSONEncoder.shared.encode(self)
            return try JSON(data: data)
        }
    }
    
}

public extension JSONDecoder {
    
    static var shared: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()
    
    static func new(_ builder: (_ decoder: JSONDecoder) -> Void) -> JSONDecoder {
        let decoder = JSONDecoder()
        builder(decoder)
        return decoder
    }
    
    static func decode<T>(_ type: T.Type,
                          from string: String,
                          using: String.Encoding = .utf8,
                          decoder: JSONDecoder = shared) throws -> T where T : Decodable {
        guard let data = string.data(using: using) else {
            throw STJSONError.decode
        }
        return try decode(type, from: data)
    }
    
    static func decode<T>(_ type: T.Type,
                          from data: Data,
                          decoder: JSONDecoder = shared) throws -> T where T : Decodable {
        return try decoder.decode(type, from: data)
    }
    
}

public extension JSONEncoder {
    
    public typealias EncoderConfiguration = (_ encoder: inout JSONEncoder) -> Void
    
    static var shared: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()
    
    static func new(_ configuration: EncoderConfiguration) -> JSONEncoder {
        var encoder = JSONEncoder()
        configuration(&encoder)
        return encoder
    }
    
    static func encode<T>(_ value: T, configuration: EncoderConfiguration) throws -> Data where T : Encodable {
        try encode(value, encoder: new(configuration))
    }
    
    static func encode<T>(_ value: T, encoder: JSONEncoder = shared) throws -> Data where T : Encodable {
        try encoder.encode(value)
    }
    
    static func encodeToJSON<T>(_ value: T, configuration: EncoderConfiguration) throws -> String where T : Encodable {
        try encodeToJSON(value, encoder: new(configuration))
    }
    
    static func encodeToJSON<T>(_ value: T, encoder: JSONEncoder = shared) throws -> String where T : Encodable {
        let data = try encoder.encode(value)
        if let str = String(data: data, encoding: .utf8) {
            return str
        } else {
            return ""
        }
    }
    
}

public extension JSON {
    
    func decode<T>(_ type: T.Type, decoder: JSONDecoder = JSONDecoder.shared) throws -> T where T : Decodable {
        return try decoder.decode(type, from: self.rawData())
    }
    
    func decode<T: JSONDecodableModel>(json type: T.Type) throws -> T where T : JSONDecodableModel {
        return try type.init(from: self)
    }
    
}
