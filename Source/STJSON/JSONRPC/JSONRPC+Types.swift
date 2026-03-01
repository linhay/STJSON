import Foundation
import AnyCodable

public extension JSONRPC {

    enum ID: Equatable, Codable {
        case string(String)
        case int(Int)
        case null

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if container.decodeNil() {
                self = .null
            } else if let int = try? container.decode(Int.self) {
                self = .int(int)
            } else if let string = try? container.decode(String.self) {
                self = .string(string)
            } else {
                throw ProtocolError.invalidRequest("`id` must be string, int, or null.")
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let value):
                try container.encode(value)
            case .int(let value):
                try container.encode(value)
            case .null:
                try container.encodeNil()
            }
        }
    }

    enum Params: Equatable, Codable {
        case object([String: AnyCodable])
        case array([AnyCodable])

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let dict = try? container.decode([String: AnyCodable].self) {
                self = .object(dict)
            } else if let array = try? container.decode([AnyCodable].self) {
                self = .array(array)
            } else {
                throw ProtocolError.invalidRequest("`params` must be object or array.")
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .object(let value):
                try container.encode(value)
            case .array(let value):
                try container.encode(value)
            }
        }
    }

    enum ErrorCode: Equatable, Codable {
        case parseError
        case invalidRequest
        case methodNotFound
        case invalidParams
        case internalError
        case custom(Int)

        public var value: Int {
            switch self {
            case .parseError:
                return -32700
            case .invalidRequest:
                return -32600
            case .methodNotFound:
                return -32601
            case .invalidParams:
                return -32602
            case .internalError:
                return -32603
            case .custom(let code):
                return code
            }
        }

        public init(_ value: Int) {
            switch value {
            case -32700:
                self = .parseError
            case -32600:
                self = .invalidRequest
            case -32601:
                self = .methodNotFound
            case -32602:
                self = .invalidParams
            case -32603:
                self = .internalError
            default:
                self = .custom(value)
            }
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let code = try container.decode(Int.self)
            self = .init(code)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(value)
        }
    }

    struct ErrorObject: Equatable, Codable {
        public let code: ErrorCode
        public let message: String
        public let data: AnyCodable?

        public init(code: ErrorCode, message: String, data: AnyCodable? = nil) {
            self.code = code
            self.message = message
            self.data = data
        }

        enum CodingKeys: String, CodingKey {
            case code
            case message
            case data
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.code = try container.decode(ErrorCode.self, forKey: .code)
            self.message = try container.decode(String.self, forKey: .message)
            self.data = try container.decodeIfPresent(AnyCodable.self, forKey: .data)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(code, forKey: .code)
            try container.encode(message, forKey: .message)
            try container.encodeIfPresent(data, forKey: .data)
        }
    }

    struct Request: Equatable, Codable {
        public let jsonrpc: String
        public let method: String
        public let params: Params?
        public let id: ID?

        public init(
            jsonrpc: String = "2.0",
            method: String,
            params: Params? = nil,
            id: ID? = nil
        ) throws {
            self.jsonrpc = jsonrpc
            self.method = method
            self.params = params
            self.id = id
            try validate()
        }

        public var isNotification: Bool { id == nil }
        public var requiresResponse: Bool { isNotification == false }

        enum CodingKeys: String, CodingKey {
            case jsonrpc
            case method
            case params
            case id
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.jsonrpc = try container.decode(String.self, forKey: .jsonrpc)
            self.method = try container.decode(String.self, forKey: .method)
            self.params = try container.decodeIfPresent(Params.self, forKey: .params)
            self.id = try container.decodeIfPresent(ID.self, forKey: .id)
            try validate()
        }

        private func validate() throws {
            guard jsonrpc == "2.0" else {
                throw ProtocolError.invalidRequest("`jsonrpc` must be \"2.0\".")
            }
            guard method.isEmpty == false else {
                throw ProtocolError.invalidRequest("`method` must not be empty.")
            }
            guard method.hasPrefix("rpc.") == false else {
                throw ProtocolError.invalidRequest("`method` with prefix `rpc.` is reserved.")
            }
        }
    }

    struct Response: Equatable, Codable {
        public let jsonrpc: String
        public let id: ID?
        public let result: AnyCodable?
        public let error: ErrorObject?

        public init(
            jsonrpc: String = "2.0",
            id: ID?,
            result: AnyCodable?,
            error: ErrorObject?
        ) throws {
            self.jsonrpc = jsonrpc
            self.id = id
            self.result = result
            self.error = error
            try validate()
        }

        enum CodingKeys: String, CodingKey {
            case jsonrpc
            case id
            case result
            case error
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.jsonrpc = try container.decodeIfPresent(String.self, forKey: .jsonrpc) ?? "2.0"
            self.id = try container.decodeIfPresent(ID.self, forKey: .id)
            self.result = try container.decodeIfPresent(AnyCodable.self, forKey: .result)
            self.error = try container.decodeIfPresent(ErrorObject.self, forKey: .error)
            try validate()
        }

        private func validate() throws {
            guard jsonrpc == "2.0" else {
                throw ProtocolError.invalidRequest("`jsonrpc` must be \"2.0\".")
            }
            let hasResult = result != nil
            let hasError = error != nil
            guard hasResult != hasError else {
                throw ProtocolError.invalidRequest("Exactly one of `result` or `error` is required.")
            }
        }
    }

    enum Inbound: Equatable, Codable {
        case single(Request)
        case batch([Request])

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            if let requests = try? container.decode([Request].self) {
                guard requests.isEmpty == false else {
                    throw ProtocolError.emptyBatch
                }
                self = .batch(requests)
                return
            }

            self = .single(try container.decode(Request.self))
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .single(let request):
                try container.encode(request)
            case .batch(let requests):
                try container.encode(requests)
            }
        }

        public func requestsRequiringResponse() -> [Request] {
            switch self {
            case .single(let request):
                return request.requiresResponse ? [request] : []
            case .batch(let requests):
                return requests.filter(\.requiresResponse)
            }
        }
    }

    enum ProtocolError: Error, Equatable {
        case parseError(String)
        case invalidRequest(String)
        case emptyBatch
        case emptyResponseBatch

        public var errorCode: ErrorCode {
            switch self {
            case .parseError:
                return .parseError
            case .invalidRequest, .emptyBatch, .emptyResponseBatch:
                return .invalidRequest
            }
        }

        public var message: String {
            switch self {
            case .parseError(let message):
                return message
            case .invalidRequest(let message):
                return message
            case .emptyBatch:
                return "Batch request must not be empty."
            case .emptyResponseBatch:
                return "Response batch must not be empty."
            }
        }

        public func toErrorObject(data: AnyCodable? = nil) -> ErrorObject {
            ErrorObject(code: errorCode, message: message, data: data)
        }
    }

}
