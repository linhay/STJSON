// MIT License
//
// Copyright (c) 2020 linhey
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

extension JSON: Equatable, Hashable {
    
    public func hash(into hasher: inout Hasher) {
        if let data = try? rawData() {
            hasher.combine(data)
        }
    }
    
}

public extension JSON {

    subscript(keys keys: String...) -> LazyMapSequence<[String], JSON> {
        return keys.lazy.map { (key) -> JSON in
            return self[key]
        }
    }

    var isExists: Bool {
        if !exists() {
            return false
        }
        if self.null != nil {
            return false
        }
        return true
    }

    var keys: [String] {
        dictionaryValue.keys.map({ $0 })
    }
    
    var dictionaryObjectValue: [String: Any] {
        dictionaryObject ?? [:]
    }
    
}

public extension LazyMapSequence where Base == [String], Element == JSON {

    var firstValue: JSON? {
        first(where: \.isExists)
    }

    var array: [JSON]? {
        firstValue?.array
    }
    
    var arrayValue: [JSON] {
        firstValue?.arrayValue ?? []
    }
    
    var string: String? {
        firstValue?.string
    }

    var stringValue: String {
        firstValue?.stringValue ?? ""
    }

    var int: Int? {
        firstValue?.int
    }

    var intValue: Int {
        firstValue?.intValue ?? 0
    }
    
    var double: Double? {
        firstValue?.double
    }

    var doubleValue: Double {
        firstValue?.double ?? 0
    }

    var bool: Bool? {
        firstValue?.bool
    }

    var boolValue: Bool {
        firstValue?.boolValue ?? false
    }

    var url: URL? {
        firstValue?.url
    }
    
    var float: Float? {
        firstValue?.float
    }

    var floatValue: Float {
        firstValue?.float ?? 0
    }
    
    var uInt: UInt? {
        firstValue?.uInt
    }

    var uIntValue: UInt {
        firstValue?.uIntValue ?? 0
    }
    
    var int8: Int8? {
        firstValue?.int8
    }

    var int8Value: Int8 {
        firstValue?.int8Value ?? 0
    }

    var uInt8: UInt8? {
        firstValue?.uInt8
    }

    var uInt8Value: UInt8 {
        firstValue?.uInt8Value ?? 0
    }
    
    var int16: Int16? {
        firstValue?.int16
    }

    var int16Value: Int16 {
        firstValue?.int16Value ?? 0
    }

    var uInt16: UInt16? {
        firstValue?.uInt16
    }

    var uInt16Value: UInt16 {
        firstValue?.uInt16Value ?? 0
    }
    
    var int64: Int64? {
        firstValue?.int64
    }

    var int64Value: Int64 {
        firstValue?.int64Value ?? 0
    }

    var uInt64: UInt64? {
        firstValue?.uInt64
    }

    var uInt64Value: UInt64 {
        firstValue?.uInt64Value ?? 0
    }
}
