//
//  ByteBufferWriterTests.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation
import Testing

@testable import DNSKit

@Suite
struct ByteBufferWriterTests {

    @Test(arguments: [1, 2, 3, 4, 5])
    func int16(value: UInt8) throws {
        var buffer = ByteBufferWriter()
        #expect(buffer.data.isEmpty)
        buffer.write(256 + UInt16(value))
        #expect(Array(buffer.data) == [1, value])
    }

    @Test
    func bool() throws {
        var buffer = ByteBufferWriter()
        #expect(buffer.data.isEmpty)
        buffer.write(false)
        buffer.write(true)
        buffer.write(false)
        buffer.write(false)
        buffer.write(true)
        #expect(Array(buffer.data) == [0, 1, 0, 0, 1])
    }

}
