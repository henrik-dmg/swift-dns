//
//  UnknownEDNSOption.swift
//  swift-dns
//

import Foundation

/// Represents an unrecognized or unsupported EDNS option.
///
/// This type preserves the raw option data for options whose code
/// is not recognized by the decoder, allowing round-trip encoding.
public struct UnknownEDNSOption: EDNSOption, EDNSOptionEncodable {

    public let code: EDNSOptionCode

    public var dataLength: UInt16 {
        UInt16(data.count)
    }

    /// The raw option data.
    public let data: Data

    /// Creates a new unknown EDNS option.
    ///
    /// - Parameters:
    ///   - code: The option code.
    ///   - data: The raw option data.
    public init(code: EDNSOptionCode, data: Data) {
        self.code = code
        self.data = data
    }

    // MARK: - Encoding

    func encodeOptionData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        buffer.write(data)
    }

}
