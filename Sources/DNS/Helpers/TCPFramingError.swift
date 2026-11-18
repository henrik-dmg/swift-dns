//
//  TCPFramingError.swift
//  swift-dns
//
//  Created by Henrik Panhans on 02.03.26.
//

import Foundation

public enum TCPFramingError: LocalizedError {

    case insufficientData(available: Int)
    case messageLengthMismatch(declared: Int, available: Int)
    case encodedPacketTooLarge(byteCount: Int)

    public var errorDescription: String? {
        switch self {
        case .insufficientData(let available):
            "TCP framing requires at least 2 bytes for the length prefix, but only \(available) bytes are available"
        case .messageLengthMismatch(let declared, let available):
            "TCP framing length mismatch: declared \(declared) bytes, but \(available) bytes available"
        case .encodedPacketTooLarge(let byteCount):
            "Encoded packet is too large for TCP framing: \(byteCount) bytes exceeds maximum of \(UInt16.max)"
        }
    }

}
