//
//  File.swift
//
//
//  Created by linhey on 2023/6/30.
//

import Foundation

/// https://jsonlines.org/
public struct JSONLines {
    
    public enum Source {
        case string(String)
        case data(Data)
        case url(URL, chunkSize: Int = 64 * 1024)
    }
    
    public struct LineCollection: Collection {
        public typealias Element = Substring
        public typealias Index = String.Index
        
        private let raw: String
        
        init(_ raw: String) {
            self.raw = raw
        }
        
        public var startIndex: String.Index {
            _nextLineStart(from: raw.startIndex)
        }
        
        public var endIndex: String.Index {
            raw.endIndex
        }
        
        public subscript(position: String.Index) -> Substring {
            precondition(position != endIndex, "Index out of bounds")
            let end = _lineEnd(from: position)
            return raw[position..<end]
        }
        
        public func index(after i: String.Index) -> String.Index {
            precondition(i != endIndex, "Cannot advance past endIndex")
            let currentEnd = _lineEnd(from: i)
            return _nextLineStart(from: currentEnd)
        }
        
        private func _lineEnd(from start: String.Index) -> String.Index {
            var index = start
            while index < raw.endIndex {
                if Self._isNewline(raw[index]) {
                    return index
                }
                index = raw.index(after: index)
            }
            return raw.endIndex
        }
        
        private func _nextLineStart(from rawIndex: String.Index) -> String.Index {
            var index = rawIndex
            while index < raw.endIndex, Self._isNewline(raw[index]) {
                index = raw.index(after: index)
            }
            return index
        }
        
        private static func _isNewline(_ character: Character) -> Bool {
            character == "\n" || character == "\r"
        }
    }
    
    public struct AsyncLineSequence: AsyncSequence {
        public typealias Element = Data
        
        private let url: URL
        private let chunkSize: Int
        
        public init(url: URL, chunkSize: Int = 64 * 1024) {
            self.url = url
            self.chunkSize = chunkSize
        }
        
        public func makeAsyncIterator() -> AsyncIterator {
            AsyncIterator(url: url, chunkSize: chunkSize)
        }
        
        public struct AsyncIterator: AsyncIteratorProtocol {
            private let url: URL
            private let chunkSize: Int
            
            private var handle: FileHandle?
            private var didReachEOF: Bool
            private var buffer: Data
            
            init(url: URL, chunkSize: Int) {
                self.url = url
                self.chunkSize = Swift.max(1, chunkSize)
                self.didReachEOF = false
                self.buffer = Data()
                self.buffer.reserveCapacity(Swift.max(1, chunkSize))
            }
            
            public mutating func next() async throws -> Data? {
                if handle == nil, !didReachEOF {
                    handle = try FileHandle(forReadingFrom: url)
                }
                
                while true {
                    if let line = Self._consumeOneLine(in: &buffer) {
                        return line
                    }
                    
                    if didReachEOF {
                        Self._trimLeadingNewlines(in: &buffer)
                        if buffer.isEmpty {
                            try _closeHandle()
                            return nil
                        }
                        let tail = buffer
                        buffer.removeAll(keepingCapacity: false)
                        try _closeHandle()
                        return tail
                    }
                    
                    guard let handle else {
                        return nil
                    }
                    let chunk = try handle.read(upToCount: chunkSize) ?? Data()
                    if chunk.isEmpty {
                        didReachEOF = true
                        continue
                    }
                    buffer.append(chunk)
                }
            }
            
            private mutating func _closeHandle() throws {
                if let handle {
                    try handle.close()
                    self.handle = nil
                }
            }
            
            private static func _consumeOneLine(in buffer: inout Data) -> Data? {
                _trimLeadingNewlines(in: &buffer)
                if buffer.isEmpty { return nil }
                
                guard let lineEnd = buffer.firstIndex(where: { _isNewline($0) }) else {
                    return nil
                }
                
                let line = Data(buffer[buffer.startIndex..<lineEnd])
                var next = lineEnd
                while next < buffer.endIndex, _isNewline(buffer[next]) {
                    next = buffer.index(after: next)
                }
                buffer.removeSubrange(buffer.startIndex..<next)
                return line
            }
            
            private static func _trimLeadingNewlines(in buffer: inout Data) {
                var firstContent = buffer.startIndex
                while firstContent < buffer.endIndex, _isNewline(buffer[firstContent]) {
                    firstContent = buffer.index(after: firstContent)
                }
                if firstContent > buffer.startIndex {
                    buffer.removeSubrange(buffer.startIndex..<firstContent)
                }
            }
            
            private static func _isNewline(_ byte: UInt8) -> Bool {
                byte == 10 || byte == 13
            }
        }
    }
    
    public init() {}
    
}

public extension JSONLines {
    
    func decode(from source: Source) throws -> [JSON] {
        try compactMapLines(from: source) { _, line in
            try JSON(data: line)
        }
    }
    
    func encode(_ jsons: [JSON]) throws -> Data {
        try _encode(jsons.map({ try $0.rawData() }))
    }
    
    func decode<C: Decodable>(from source: Source, decoder: JSONDecoder = JSONDecoder()) throws -> [C] {
        try compactMapLines(from: source) { _, line in
            try decoder.decode(C.self, from: line)
        }
    }
    
    func encode(_ jsons: [any Encodable], encoder: JSONEncoder) throws -> Data {
        try _encode(try jsons.map({ try encoder.encode($0) }))
    }
    
    /// Transform non-empty lines from a JSONLines string.
    /// - Note: The closure controls skip/collect behaviors by returning `nil` or handling thrown decode errors manually.
    func compactMapLines<T>(
        from source: Source,
        _ transform: (_ lineNumber: Int, _ line: Data) throws -> T?
    ) throws -> [T] {
        var result: [T] = []
        switch source {
        case .string(let string):
            try _forEachLineData(string) { lineNumber, lineData in
                if let value = try transform(lineNumber, lineData) {
                    result.append(value)
                }
            }
        case .data(let data):
            try _forEachLineData(data) { lineNumber, lineData in
                if let value = try transform(lineNumber, lineData) {
                    result.append(value)
                }
            }
        case .url(let url, let chunkSize):
            try _forEachLineData(url: url, chunkSize: chunkSize) { lineNumber, lineData in
                if let value = try transform(lineNumber, lineData) {
                    result.append(value)
                }
            }
        }        
        return result
    }
    
    /// Return a lazy line collection for JSONLines content.
    /// Empty lines are skipped.
    func lines(_ string: String) -> LineCollection {
        LineCollection(string)
    }
    
    /// Return an async sequence for line-by-line JSONLines reading from file URL.
    func asyncLines(url: URL, chunkSize: Int = 64 * 1024) -> AsyncLineSequence {
        AsyncLineSequence(url: url, chunkSize: chunkSize)
    }

    func forEachLine(from source: Source, _ body: (JSON) throws -> Void) throws {
        _ = try compactMapLines(from: source) { _, line in
            try body(try JSON(data: line))
            return Optional<Void>.none
        }
    }

    /// Read JSONLines line-by-line and decode each line to `C`.
    /// This avoids creating an intermediate decoded array in memory.
    func forEachLine<C: Decodable>(
        from source: Source,
        decoder: JSONDecoder = JSONDecoder(),
        _ body: (C) throws -> Void
    ) throws {
        _ = try compactMapLines(from: source) { _, line in
            try body(try decoder.decode(C.self, from: line))
            return Optional<Void>.none
        }
    }
    
    /// Async line-by-line JSON decode from file URL.
    func forEachLineAsync(
        url: URL,
        chunkSize: Int = 64 * 1024,
        _ body: (JSON) async throws -> Void
    ) async throws {
        for try await lineData in asyncLines(url: url, chunkSize: chunkSize) {
            try await body(try JSON(data: lineData))
        }
    }
    
    /// Async line-by-line Decodable decode from file URL.
    func forEachLineAsync<C: Decodable>(
        url: URL,
        chunkSize: Int = 64 * 1024,
        decoder: JSONDecoder,
        _ body: (C) async throws -> Void
    ) async throws {
        for try await lineData in asyncLines(url: url, chunkSize: chunkSize) {
            try await body(try decoder.decode(C.self, from: lineData))
        }
    }
    
    /// Async transform for line-by-line JSONLines processing from file URL.
    func compactMapLinesAsync<T>(
        url: URL,
        chunkSize: Int = 64 * 1024,
        _ transform: (_ lineNumber: Int, _ line: Data) async throws -> T?
    ) async throws -> [T] {
        var result: [T] = []
        var lineNumber = 0
        for try await lineData in asyncLines(url: url, chunkSize: chunkSize) {
            lineNumber += 1
            if let value = try await transform(lineNumber, lineData) {
                result.append(value)
            }
        }
        return result
    }
    
}

private extension JSONLines {

    func _forEachLineData(_ string: String, _ body: (_ lineNumber: Int, _ line: Data) throws -> Void) throws {
        var lineNumber = 0
        for line in lines(string) {
            let data = Data(line.utf8)
            if data.isEmpty {
                throw STJSONError.invalidData
            }
            lineNumber += 1
            try body(lineNumber, data)
        }
    }
    
    func _forEachLineData(_ data: Data, _ body: (_ lineNumber: Int, _ line: Data) throws -> Void) throws {
        var lineNumber = 0
        var lineStart = data.startIndex
        var index = data.startIndex
        
        while index < data.endIndex {
            if _isNewline(data[index]) {
                if lineStart < index {
                    lineNumber += 1
                    try body(lineNumber, Data(data[lineStart..<index]))
                }
                index = data.index(after: index)
                while index < data.endIndex, _isNewline(data[index]) {
                    index = data.index(after: index)
                }
                lineStart = index
                continue
            }
            index = data.index(after: index)
        }
        
        if lineStart < data.endIndex {
            lineNumber += 1
            try body(lineNumber, Data(data[lineStart..<data.endIndex]))
        }
    }
    
    func _forEachLineData(url: URL, chunkSize: Int, _ body: (_ lineNumber: Int, _ line: Data) throws -> Void) throws {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        
        var buffer = Data()
        buffer.reserveCapacity(chunkSize)
        var lineNumber = 0
        
        while true {
            let chunk = try handle.read(upToCount: chunkSize) ?? Data()
            if chunk.isEmpty { break }
            buffer.append(chunk)
            try _consumeCompleteLines(in: &buffer, lineNumber: &lineNumber, body)
        }
        
        if !buffer.isEmpty {
            try _forEachLineData(buffer) { relativeLineNumber, line in
                lineNumber += 1
                _ = relativeLineNumber
                try body(lineNumber, line)
            }
        }
    }
    
    func _consumeCompleteLines(
        in buffer: inout Data,
        lineNumber: inout Int,
        _ body: (_ lineNumber: Int, _ line: Data) throws -> Void
    ) throws {
        var lineStart = buffer.startIndex
        var index = buffer.startIndex
        var consumedUntil = buffer.startIndex
        
        while index < buffer.endIndex {
            if _isNewline(buffer[index]) {
                if lineStart < index {
                    lineNumber += 1
                    try body(lineNumber, Data(buffer[lineStart..<index]))
                }
                index = buffer.index(after: index)
                while index < buffer.endIndex, _isNewline(buffer[index]) {
                    index = buffer.index(after: index)
                }
                consumedUntil = index
                lineStart = index
                continue
            }
            index = buffer.index(after: index)
        }
        
        if consumedUntil > buffer.startIndex {
            buffer.removeSubrange(buffer.startIndex..<consumedUntil)
        }
    }
    
    func _isNewline(_ byte: UInt8) -> Bool {
        byte == 10 || byte == 13
    }
    
    func _encode(_ data: [Data]) throws -> Data {
        guard let separator = "\n".data(using: .utf8) else {
            throw STJSONError.invalidData
        }
        return Data(data.joined(separator: separator))
    }
    
    
}
