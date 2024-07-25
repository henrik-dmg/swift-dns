//
//  DNSLabels.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

struct DNSLabels {

    enum DecodeError: LocalizedError {
        case cantConvertToString(bytes: Data)
        case noLabelsDecoded
        case maximumNumberOfJumpsReached
    }

    static let maxAllowedJumps = 5
    static let jumpDirective: UInt8 = 0xC0

    let labels: [String]

}

extension DNSLabels {

    static func decode(from byteBuffer: inout ByteBuffer) throws -> DNSLabels {
        var labels: [String] = []

        let initialPosition = byteBuffer.position
        var hasJumped = false
        var jumpsPerformed = 0

        while true {
            guard jumpsPerformed <= DNSLabels.maxAllowedJumps else {
                throw DecodeError.maximumNumberOfJumpsReached
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
                print("Jumping to \(labelOffset)", labelLength, jumpDestinationByte)
                try byteBuffer.seek(Int(labelOffset))
            } else {
                let labelBytes = try byteBuffer.readBytes(Int(labelLength))
                if let label = String(data: labelBytes, encoding: .utf8) {
                    labels.append(label)
                } else {
                    throw DecodeError.cantConvertToString(bytes: labelBytes)
                }
            }
        }

        if hasJumped {
            try byteBuffer.seek(initialPosition + 2)  // +2 because if we jumped, we need to skip past the two jump directive bytes
        }

        guard !labels.isEmpty else {
            throw DecodeError.noLabelsDecoded
        }

        return DNSLabels(labels: labels)
    }

}
