//
//  PaddingOption.swift
//  swift-dns
//

import Foundation

/// Represents the Padding EDNS option (RFC 7830).
///
/// The padding option can be used to pad DNS messages to a specific size,
/// making it harder for observers to correlate encrypted DNS traffic
/// with specific queries based on message length.
public struct PaddingOption: EDNSOption, EDNSOptionEncodable {

    // MARK: - Properties

    public let code: EDNSOptionCode = .padding

    public var dataLength: UInt16 {
        UInt16(padding.count)
    }

    /// The padding data (typically zero-filled bytes).
    public let padding: Data

    // MARK: - Init

    /// Creates a new Padding option.
    ///
    /// - Parameter padding: The padding data.
    public init(padding: Data) {
        self.padding = padding
    }

    /// Creates a new Padding option with the specified number of zero bytes.
    ///
    /// - Parameter length: The number of zero bytes to use as padding.
    public init(length: UInt16) {
        self.padding = Data(count: Int(length))
    }

    // MARK: - Encoding

    func encodeOptionData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        buffer.write(padding)
    }

}
