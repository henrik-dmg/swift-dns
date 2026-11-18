//
//  EDNSOption.swift
//  swift-dns
//

import Foundation

// MARK: - Base Protocol

/// The base protocol for all EDNS options.
///
/// EDNS options are carried in the RDATA of an OPT pseudo-record (RFC 6891).
/// Each option has a code identifying its type and variable-length data.
public protocol EDNSOption: Equatable, Sendable {

    /// The option code identifying this EDNS option type.
    var code: EDNSOptionCode { get }

    /// The length in bytes of the option data (excluding the code and length fields).
    var dataLength: UInt16 { get }

}

/// Internal protocol for encoding EDNS option-specific data.
protocol EDNSOptionEncodable {

    func encodeOptionData(into buffer: inout ByteBufferWriting) throws(EncoderError)

}

// MARK: - Encoding

extension EDNSOption {

    /// Encodes the complete EDNS option into the provided buffer.
    ///
    /// Writes the option code, data length, then delegates to the option-specific encoding.
    func encode(into buffer: inout ByteBufferWriting) throws {
        try code.encode(into: &buffer)
        buffer.write(dataLength)

        if let encodable = self as? EDNSOptionEncodable {
            try encodable.encodeOptionData(into: &buffer)
        }
    }

}
