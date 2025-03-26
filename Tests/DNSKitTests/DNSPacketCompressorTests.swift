import Foundation
import Testing

@testable import DNSKit

struct DNSPacketCompressorTests {

    @Test("writes uncompressed labels with null terminator")
    func uncompressedWrite() throws {
        var compressor = DNSPacketCompressor()
        let labels = DNSLabels(labels: ["www", "example", "com"])

        try compressor.write(labels)

        let expected: [UInt8] = [
            3, 119, 119, 119,
            7, 101, 120, 97, 109, 112, 108, 101,
            3, 99, 111, 109,
            0,
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

    @Test("throws if compression is used but does not end with jump")
    func compressionMustEndWithJump() throws {
        var compressor = DNSPacketCompressor()

        // Write one label, simulate a jump, but then leave remaining labels uncompressed
        try compressor.write(DNSLabels(labels: ["www"]))
        // compressor.labelPositions.append(DNSLabelPosition(index: 0, label: "www"))

        let labels = DNSLabels(labels: ["www", "example", "com"])

        // This should fail because the compression did not end with a jump
        #expect {
            try compressor.write(labels)
        } throws: { error in
            guard let encoderError = error as? EncoderError else {
                return false
            }
            switch encoderError {
            case .didNotWriteJumpDirectiveLast:
                return true
            default:
                return false
            }
        }
    }

}
