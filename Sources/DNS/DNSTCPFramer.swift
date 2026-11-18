//
//  DNSTCPFramer.swift
//  swift-dns
//
//  Created by Henrik Panhans on 02.03.26.
//

import Foundation

/// Encodes and decodes DNS packets with the 2-byte big-endian length prefix required by RFC 1035 §4.2.2.
public struct DNSTCPFramer {

    public var shouldCompressLabels: Bool = true

    public init() {}

    public func encode(packet: DNSPacket) throws -> Data {
        var encoder = DNSPacketEncoder()
        encoder.shouldCompressLabels = shouldCompressLabels
        let wireData = try encoder.encode(packet: packet)

        guard wireData.count <= Int(UInt16.max) else {
            throw TCPFramingError.encodedPacketTooLarge(byteCount: wireData.count)
        }

        let length = UInt16(wireData.count)
        var result = Data(capacity: 2 + wireData.count)
        result.append(UInt8(length >> 8))
        result.append(UInt8(length & 0xFF))
        result.append(wireData)
        return result
    }

    public func decode(from data: Data) throws -> DNSPacket {
        guard data.count >= 2 else {
            throw TCPFramingError.insufficientData(available: data.count)
        }
        let high = Int(data[data.startIndex])
        let low = Int(data[data.startIndex + 1])
        let declaredLength = (high << 8) | low
        let available = data.count - 2
        guard declaredLength == available else {
            throw TCPFramingError.messageLengthMismatch(declared: declaredLength, available: available)
        }
        let body = Data(data.dropFirst(2))  // rebase to startIndex = 0 — critical
        return try DNSPacketDecoder().decode(from: body)
    }

}
