//
//  NSIDOption.swift
//  swift-dns
//

// swift-format-ignore: AlwaysUseLowerCamelCase

import Foundation

/// Represents the Name Server Identifier (NSID) EDNS option (RFC 5001).
///
/// The NSID option allows a client to request, and a server to provide,
/// an opaque identifier for the name server that handled the query.
public struct NSIDOption: EDNSOption, EDNSOptionEncodable {

    public let code: EDNSOptionCode = .nsid

    public var dataLength: UInt16 {
        UInt16(payload.count)
    }

    /// The opaque name server identifier.
    public let payload: Data

    /// Creates a new NSID option.
    ///
    /// - Parameter payload: The opaque server identifier data.
    public init(payload: Data) {
        self.payload = payload
    }

    // MARK: - Encoding

    func encodeOptionData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        buffer.write(payload)
    }

}
