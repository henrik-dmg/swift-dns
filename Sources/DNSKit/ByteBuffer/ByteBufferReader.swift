//
//  ByteBufferReader.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

public protocol ByteBufferReading: ByteBuffer {

    mutating func readByte() throws -> UInt8
    mutating func readUInt16() throws -> UInt16
    mutating func readUInt32() throws -> UInt32
    mutating func readBytes(_ count: Int) throws -> Data

}

struct ByteBufferReader: ByteBufferReading {

    // MARK: - Properties

    let data: Data
    var currentIndex: Data.Index = 0

    // MARK: - Init

    init(_ data: [UInt8]) {
        self.data = Data(data)
    }

    init(_ data: Data) {
        self.data = data
    }

    // MARK: - Methods

    mutating func readByte() throws -> UInt8 {
        try readBytes(1)[0]
    }

    mutating func readUInt16() throws -> UInt16 {
        let bytes = try readBytes(2)
        return UInt16(bytes[0]) << 8 + UInt16(bytes[1])
    }

    mutating func readUInt32() throws -> UInt32 {
        UInt32(try readUInt16()) << 16 + UInt32(try readUInt16())
    }

    mutating func readBytes(_ count: Int) throws -> Data {
        guard let endIndex = data.index(currentIndex, offsetBy: count, limitedBy: data.endIndex) else {
            throw ByteBufferError.indexOutOfBounds(currentIndex, data.endIndex)
        }
        let subData = data.subdata(in: currentIndex ..< endIndex)
        currentIndex = endIndex
        return subData
    }

}
