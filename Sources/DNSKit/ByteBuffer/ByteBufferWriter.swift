//
//  ByteBufferWriter.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

public protocol ByteBufferWriting: ByteBuffer {

    mutating func write(_ value: UInt32)
    mutating func write(_ value: UInt16)
    mutating func write(_ value: UInt8)
    mutating func write(_ value: Bool)
    mutating func write(_ bytes: [UInt8])
    mutating func write(_ data: Data)
    mutating func write(_ labels: DNSLabels) throws

}

struct ByteBufferWriter: ByteBufferWriting {

    // MARK: - Properties

    private(set) var data: Data

    var currentIndex: Data.Index { data.endIndex }

    // MARK: - Init

    init(_ data: Data = Data()) { self.data = data }

    // MARK: - Methods

    mutating func write(_ value: UInt32) {
        let firstHalf = UInt16(value >> 16)
        let secondHalf = UInt16(value & 0xFFFF)
        write(firstHalf)
        write(secondHalf)
    }

    mutating func write(_ value: UInt16) {
        let firstHalf = UInt8(value >> 8)
        let secondHalf = UInt8(value & 0xFF)
        data.append(firstHalf)
        data.append(secondHalf)
    }

    mutating func write(_ value: UInt8) { data.append(value) }

    mutating func write(_ value: Bool) { data.append(value ? 1 : 0) }

    mutating func write(_ bytes: [UInt8]) { data.append(contentsOf: bytes) }

    mutating func write(_ data: Data) { self.data.append(data) }

    mutating func write(_ labels: DNSLabels) throws {
        for label in labels.labels { try write(label) }
        // Write single zero to signal termination of label sequence
        write(UInt8(0))
    }

    mutating func write(_ label: String) throws {
        guard label.count < 63 else {
            throw EncoderError.labelTooLong(label: label)
        }
        guard let labelData = label.data(using: .ascii) else {
            throw EncoderError.cantEncodeLabel(label: label)
        }
        write(UInt8(label.count))
        write(Array(labelData))
    }

}
