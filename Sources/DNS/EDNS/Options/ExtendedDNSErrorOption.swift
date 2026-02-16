//
//  ExtendedDNSErrorOption.swift
//  swift-dns
//

import Foundation

/// Represents the Extended DNS Error EDNS option (RFC 8914).
///
/// This option provides additional information about the cause of DNS errors,
/// beyond what the RCODE alone can convey. It includes a numeric info code
/// and an optional human-readable extra text field.
public struct ExtendedDNSErrorOption: EDNSOption, EDNSOptionEncodable {

    // MARK: - Properties

    public let code: EDNSOptionCode = .extendedDNSError

    public var dataLength: UInt16 {
        // infoCode (2) + extra text bytes
        let textLength = extraText?.utf8.count ?? 0
        return UInt16(2 + textLength)
    }

    /// The extended error info code as defined in RFC 8914.
    public let infoCode: UInt16

    /// Optional human-readable extra text providing more detail about the error.
    public let extraText: String?

    // MARK: - Init

    /// Creates a new Extended DNS Error option.
    ///
    /// - Parameters:
    ///   - infoCode: The numeric error info code.
    ///   - extraText: Optional human-readable error detail.
    public init(infoCode: UInt16, extraText: String? = nil) {
        self.infoCode = infoCode
        self.extraText = extraText
    }

    // MARK: - Encoding

    func encodeOptionData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        buffer.write(infoCode)
        if let extraText {
            guard let textData = extraText.data(using: .utf8) else {
                throw EncoderError.cantConvertStringToData(extraText)
            }
            buffer.write(textData)
        }
    }

}
