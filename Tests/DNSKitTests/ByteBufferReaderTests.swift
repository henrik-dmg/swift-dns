//
//  ContiguousBytes+ExtensionsTests.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation
import Testing

@testable import DNSKit

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

}
