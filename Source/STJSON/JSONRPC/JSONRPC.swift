import Foundation

public enum JSONRPC {}

public extension JSONRPC {

    static func decodeInbound(from data: Data, decoder: JSONDecoder = JSONDecoder()) throws -> Inbound {
        do {
            return try decoder.decode(Inbound.self, from: data)
        } catch let error as ProtocolError {
            throw error
        } catch {
            throw ProtocolError.parseError("Invalid JSON payload.")
        }
    }

    static func encodeResponse(_ response: Response, encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        try encoder.encode(response)
    }

    static func encodeResponses(_ responses: [Response], encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        guard responses.isEmpty == false else {
            throw ProtocolError.emptyResponseBatch
        }
        return try encoder.encode(responses)
    }

}
