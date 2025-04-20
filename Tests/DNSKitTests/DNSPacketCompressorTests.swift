import Foundation
import Testing

@testable import DNSKit

@Suite
struct DNSPacketCompressorTests {

    @Test("writes uncompressed labels with null terminator")
    func uncompressedWrite() throws {
        var compressor = DNSPacketCompressor()
        let labels = DNSLabels(labels: ["www", "example", "com"])

        try compressor.write(labels)

        let expected: [UInt8] = [
            3, 119, 119, 119, 7, 101, 120, 97, 109, 112, 108, 101, 3, 99, 111, 109, 0,
        ]

        #expect(compressor.data == Data(expected))
    }

    @Test("writes compressed labels using pointer")
    func compressedWrite() throws {
        var compressor = DNSPacketCompressor()

        // First write: "example.com"
        try compressor.write(DNSLabels(labels: ["example", "com"]))

        // Second write: "www.example.com" — should compress using pointer
        try compressor.write(DNSLabels(labels: ["www", "example", "com"]))

        let expected: [UInt8] = [
            7, 101, 120, 97, 109, 112, 108, 101,  // "example"
            3, 99, 111, 109,  // "com"
            0,  // end of first write
            3, 119, 119, 119,  // "www"
            0xC0, 0x00,  // pointer to offset 0
        ]

        #expect(compressor.data == Data(expected))
    }

}
