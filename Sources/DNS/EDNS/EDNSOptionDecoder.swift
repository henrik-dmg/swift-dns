//
//  EDNSOptionDecoder.swift
//  swift-dns
//

import Foundation

struct EDNSOptionDecoder {

    /// Decodes an EDNS option from the byte buffer.
    ///
    /// Reads the option code and data length, then dispatches to the appropriate
    /// concrete option type based on the code. Unrecognized codes are decoded
    /// as ``UnknownEDNSOption``.
    static func decode(from buffer: inout ByteBufferReading) throws -> any EDNSOption {
        let code = try EDNSOptionCode.decode(from: &buffer)
        let dataLength = try buffer.readUInt16()
        let optionStart = buffer.currentIndex

        let option: any EDNSOption
        switch code {
        case .nsid:
            let payload = try buffer.readBytes(Int(dataLength))
            option = NSIDOption(payload: payload)

        case .clientSubnet:
            guard dataLength >= 4 else {
                throw DecoderError.invalidEDNSOptionLength(code: .clientSubnet, length: dataLength, minimum: 4)
            }
            let family = try buffer.readUInt16()
            let sourcePrefixLength = try buffer.readByte()
            let scopePrefixLength = try buffer.readByte()
            let address = try buffer.readBytes(Int(dataLength) - 4)
            option = ClientSubnetOption(
                family: family,
                sourcePrefixLength: sourcePrefixLength,
                scopePrefixLength: scopePrefixLength,
                address: address
            )

        case .cookie:
            guard dataLength >= 8 else {
                throw DecoderError.invalidEDNSOptionLength(code: .cookie, length: dataLength, minimum: 8)
            }
            let clientCookie = try buffer.readBytes(8)
            let remainingLength = Int(dataLength) - 8
            let serverCookie: Data? = remainingLength > 0 ? try buffer.readBytes(remainingLength) : nil
            option = CookieOption(clientCookie: clientCookie, serverCookie: serverCookie)

        case .padding:
            let padding = try buffer.readBytes(Int(dataLength))
            option = PaddingOption(padding: padding)

        case .extendedDNSError:
            guard dataLength >= 2 else {
                throw DecoderError.invalidEDNSOptionLength(code: .extendedDNSError, length: dataLength, minimum: 2)
            }
            let infoCode = try buffer.readUInt16()
            let textLength = Int(dataLength) - 2
            let extraText: String?
            if textLength > 0 {
                let textData = try buffer.readBytes(textLength)
                extraText = String(data: textData, encoding: .utf8)
            } else {
                extraText = nil
            }
            option = ExtendedDNSErrorOption(infoCode: infoCode, extraText: extraText)

        case .unknown:
            let data = try buffer.readBytes(Int(dataLength))
            option = UnknownEDNSOption(code: code, data: data)
        }

        let consumed = UInt16(buffer.currentIndex - optionStart)
        guard consumed == dataLength else {
            throw DecoderError.ednsOptionLengthMismatch(code: code, expected: dataLength, actual: consumed)
        }
        return option
    }

}
