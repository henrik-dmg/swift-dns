//
//  ContiguousBytes+ExtensionsTests.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation
import Testing

@testable import DNS

@Suite
struct ByteBufferReaderTests {

    @Test("reads uint16", arguments: [1, 2, 3, 4, 5])
    func int16(value: UInt8) throws {
        var buffer = ByteBufferReader(Data([0, value]))
        let int = try buffer.readUInt16()
        #expect(int == value)
    }

    @Test("reads shifted uint16", arguments: [1, 2, 3, 4, 5])
    func int16Bigger(value: UInt8) throws {
        var buffer = ByteBufferReader(Data([1, value]))
        let int = try buffer.readUInt16()
        let expectedValue = UInt16(value) + UInt16(UInt8.max) + 1
        #expect(int == expectedValue)
    }

    @Test("seeks to valid index within buffer")
    func seekToValidIndex() throws {
        let data = Data([1, 2, 3, 4, 5])
        var buffer = ByteBufferReader(data)

        // Seek to middle of buffer
        try buffer.seek(2)
        #expect(buffer.currentIndex == 2)

        let byte = try buffer.readByte()
        #expect(byte == 3)  // Third byte (index 2)
    }

    @Test("seeks to startIndex")
    func seekToStartIndex() throws {
        let data = Data([1, 2, 3, 4, 5])
        var buffer = ByteBufferReader(data)

        // Read some bytes first
        _ = try buffer.readUInt16()
        #expect(buffer.currentIndex == 2)

        // Seek back to start
        try buffer.seek(data.startIndex)
        #expect(buffer.currentIndex == data.startIndex)

        let byte = try buffer.readByte()
        #expect(byte == 1)  // First byte
    }

    @Test("seeks to endIndex successfully")
    func seekToEndIndex() throws {
        let data = Data([1, 2, 3, 4, 5])
        var buffer = ByteBufferReader(data)

        // Seek to end of buffer - this should succeed
        try buffer.seek(data.endIndex)
        #expect(buffer.currentIndex == data.endIndex)
        #expect(buffer.currentIndex == 5)
    }

    @Test("throws when seeking beyond endIndex")
    func seekBeyondEndIndex() throws {
        let data = Data([1, 2, 3, 4, 5])
        var buffer = ByteBufferReader(data)

        // Seeking beyond endIndex should throw
        #expect(throws: ByteBufferError.self) {
            try buffer.seek(data.endIndex + 1)
        }
    }

    @Test("throws when seeking to negative index")
    func seekToNegativeIndex() throws {
        let data = Data([1, 2, 3, 4, 5])
        var buffer = ByteBufferReader(data)

        // Seeking to negative index should throw
        #expect(throws: ByteBufferError.self) {
            try buffer.seek(-1)
        }
    }

    @Test("readBytes positions cursor at endIndex when reading entire buffer")
    func readEntireBufferPositionsCursorAtEnd() throws {
        let data = Data([1, 2, 3, 4, 5])
        var buffer = ByteBufferReader(data)

        _ = try buffer.readBytes(5)
        #expect(buffer.currentIndex == data.endIndex)
        #expect(buffer.currentIndex == 5)
    }

}
