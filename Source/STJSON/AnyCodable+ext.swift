//
//  AnyCodable+ext.swift
//  STJSON
//
//  Created by linhey on 11/24/25.
//

import AnyCodable
import SwiftyJSON
import Foundation

public extension AnyCodable {
    
    func decode<T: Decodable>(to type: T.Type) throws -> T {
        let data = try JSONEncoder().encode(self)
        return try JSONDecoder().decode(type, from: data)
    }
    
    func toJSON() throws -> JSON {
        let data = try JSONEncoder().encode(self)
        return try JSON(data: data)
    }
    
}

public extension JSON {
    
    func decode<T: Decodable>(to type: T.Type) throws -> T {
        let data = try self.rawData()
        return try JSONDecoder().decode(type, from: data)
    }
    
}
