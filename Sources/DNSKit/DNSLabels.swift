//
//  DNSLabels.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

public struct DNSLabels: Equatable, Sendable {

    // MARK: - Nested Types

    enum DecoderError: LocalizedError {
        case cantConvertToString(bytes: Data)
        case noLabelsDecoded
        case maximumNumberOfJumpsReached
    }

    enum EncoderError: LocalizedError {
        case labelTooLong(label: String)
        case cantEncodeLabel(label: String)
    }

    // MARK: - Properties

    static let maxAllowedJumps = 5
    static let jumpDirective: UInt8 = 0xC0

    public let labels: [String]

}

// MARK: - Decoding

extension DNSLabels: DNSPacketDecodable {

    static func decode(from byteBuffer: inout ByteBufferReader) throws -> DNSLabels {
        var labels: [String] = []

        let initialPosition = byteBuffer.currentIndex
        var hasJumped = false
        var jumpsPerformed = 0

        while true {
            guard jumpsPerformed <= DNSLabels.maxAllowedJumps else {
                throw DecoderError.maximumNumberOfJumpsReached
            }

            let labelLength = try byteBuffer.readByte()
            guard labelLength != 0 else {
                break
            }

            // if two most significant bit of label length are set, this means a jump directive.
            if (labelLength & Self.jumpDirective) == Self.jumpDirective {
                hasJumped = true
                let jumpDestinationByte = try byteBuffer.readByte()
                let labelOffset = UInt16(labelLength ^ Self.jumpDirective) << 8 + UInt16(jumpDestinationByte)
                jumpsPerformed += 1
                try byteBuffer.seek(Int(labelOffset))
            } else {
                let labelBytes = try byteBuffer.readBytes(Int(labelLength))
                if let label = String(data: labelBytes, encoding: .ascii) {
                    labels.append(label)
                } else {
                    throw DecoderError.cantConvertToString(bytes: labelBytes)
                }
            }
        }

        if hasJumped {
            try byteBuffer.seek(initialPosition + 2)  // +2 because if we jumped, we need to skip past the two jump directive bytes
        }

        guard !labels.isEmpty else {
            throw DecoderError.noLabelsDecoded
        }

        return DNSLabels(labels: labels)
    }

}

// MARK: - Encoding

extension DNSLabels: DNSPacketEncodable {

    func encode(into byteBuffer: inout ByteBufferWriter) throws {
        for label in self.labels {
            guard label.count < 63 else {
                throw EncoderError.labelTooLong(label: label)
            }
            guard let labelData = label.data(using: .ascii) else {
                throw EncoderError.cantEncodeLabel(label: label)
            }
            byteBuffer.write(UInt8(label.count))
            byteBuffer.write(Array(labelData))
        }
        // Write single zero to signal termination of label sequence
        byteBuffer.write(UInt8(0))
    }

}
