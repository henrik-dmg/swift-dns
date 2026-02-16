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

        switch code {
        case .nsid:
            let payload = try buffer.readBytes(Int(dataLength))
            return NSIDOption(payload: payload)

        case .clientSubnet:
            let family = try buffer.readUInt16()
            let sourcePrefixLength = try buffer.readByte()
            let scopePrefixLength = try buffer.readByte()
            let addressLength = Int(dataLength) - 4
            let address = try buffer.readBytes(addressLength)
            return ClientSubnetOption(
                family: family,
                sourcePrefixLength: sourcePrefixLength,
                scopePrefixLength: scopePrefixLength,
                address: address
            )

        case .cookie:
            let clientCookie = try buffer.readBytes(8)
            let remainingLength = Int(dataLength) - 8
            let serverCookie: Data? = remainingLength > 0 ? try buffer.readBytes(remainingLength) : nil
            return CookieOption(clientCookie: clientCookie, serverCookie: serverCookie)

        case .padding:
            let padding = try buffer.readBytes(Int(dataLength))
            return PaddingOption(padding: padding)

        case .extendedDNSError:
            let infoCode = try buffer.readUInt16()
            let textLength = Int(dataLength) - 2
            let extraText: String?
            if textLength > 0 {
                let textData = try buffer.readBytes(textLength)
                extraText = String(data: textData, encoding: .utf8)
            } else {
                extraText = nil
            }
            return ExtendedDNSErrorOption(infoCode: infoCode, extraText: extraText)

        case .unknown:
            let data = try buffer.readBytes(Int(dataLength))
            return UnknownEDNSOption(code: code, data: data)
        }
    }

}
