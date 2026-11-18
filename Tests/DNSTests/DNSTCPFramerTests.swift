//
//  DNSTCPFramerTests.swift
//  swift-dns
//
//  Created by Henrik Panhans on 02.03.26.
//

import Foundation
import Testing
@testable import DNS

@Suite
struct DNSTCPFramerTests {

    // MARK: - Helpers

    private func makeQueryPacket() throws -> DNSPacket {
        try DNSPacket(
            id: 1234,
            queries: [DNSQuery(labels: ["example", "com"], recordType: .a, recordClass: 1)]
        )
    }

    private func makeMultiLabelPacket() throws -> DNSPacket {
        try DNSPacket(
            id: 5678,
            queries: [
                DNSQuery(labels: ["mail", "example", "com"], recordType: .a, recordClass: 1),
                DNSQuery(labels: ["example", "com"], recordType: .aaaa, recordClass: 1),
            ]
        )
    }

    // MARK: - Encoding

    @Test("encode prepends 2-byte big-endian length prefix")
    func encodePrependsTwoBytePrefix() throws {
        let packet = try makeQueryPacket()
        let framer = DNSTCPFramer()

        let framed = try framer.encode(packet: packet)

        var encoder = DNSPacketEncoder()
        encoder.shouldCompressLabels = framer.shouldCompressLabels
        let wireData = try encoder.encode(packet: packet)

        #expect(framed.count == wireData.count + 2)
        #expect(Int(framed[0]) << 8 | Int(framed[1]) == wireData.count)
    }

    // MARK: - Round-Trip

    @Test("decode returns original packet after encode")
    func roundTrip() throws {
        let original = try makeQueryPacket()
        let framer = DNSTCPFramer()

        let framed = try framer.encode(packet: original)
        let decoded = try framer.decode(from: framed)

        #expect(decoded == original)
    }

    // MARK: - Error Cases

    @Test("decode throws on declared length mismatch")
    func decodeThrowsOnLengthMismatch() throws {
        var data = Data()
        // Prefix declares 100 bytes, but only 10 body bytes follow
        data.append(0x00)
        data.append(0x64)  // 100 in big-endian
        data.append(contentsOf: [UInt8](repeating: 0xAA, count: 10))

        let framer = DNSTCPFramer()
        #expect(throws: TCPFramingError.self) {
            try framer.decode(from: data)
        }
    }

    @Test("decode throws on insufficient data (1 byte)")
    func decodeThrowsOnInsufficientData() throws {
        let data = Data([0x00])
        let framer = DNSTCPFramer()
        #expect(throws: TCPFramingError.self) {
            try framer.decode(from: data)
        }
    }

    @Test("decode throws on empty data")
    func decodeThrowsOnEmptyData() throws {
        let data = Data()
        let framer = DNSTCPFramer()
        #expect(throws: TCPFramingError.self) {
            try framer.decode(from: data)
        }
    }

    // MARK: - Compression

    @Test("shouldCompressLabels is propagated to encoder")
    func compressionPropagation() throws {
        let packet = try makeMultiLabelPacket()

        var compressedFramer = DNSTCPFramer()
        compressedFramer.shouldCompressLabels = true
        let compressed = try compressedFramer.encode(packet: packet)

        var uncompressedFramer = DNSTCPFramer()
        uncompressedFramer.shouldCompressLabels = false
        let uncompressed = try uncompressedFramer.encode(packet: packet)

        // Compressed output should be same size or smaller
        #expect(compressed.count <= uncompressed.count)
    }

}
