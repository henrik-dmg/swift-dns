//
//  ByteBufferReader.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

protocol ByteBufferReading: ByteBuffer {

    var currentIndex: Data.Index { get set }

    mutating func seek(_ index: Data.Index) throws

    mutating func readByte() throws -> UInt8
    mutating func readUInt16() throws -> UInt16
    mutating func readUInt32() throws -> UInt32
    mutating func readBytes(_ count: Int) throws -> Data

}

extension ByteBufferReading {

    mutating func seek(_ index: Data.Index) throws {
        guard data.indices.contains(index) else {
            throw ByteBufferError.indexOutOfBounds(index, data.endIndex)
        }
        currentIndex = index
    }

}

struct ByteBufferReader: ByteBufferReading {

    // MARK: - Properties

    let data: Data
    var currentIndex: Data.Index = 0

    // MARK: - Init

    init(_ data: Data) { self.data = data }

    // MARK: - Methods

    mutating func readByte() throws -> UInt8 { try readBytes(1)[0] }

    mutating func readUInt16() throws -> UInt16 {
        let bytes = try readBytes(2)
        return join(bytes[0], bytes[1])
    }

    mutating func readUInt32() throws -> UInt32 {
        let (lhs, rhs) = (try readUInt16(), try readUInt16())
        return join(lhs, rhs)
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
