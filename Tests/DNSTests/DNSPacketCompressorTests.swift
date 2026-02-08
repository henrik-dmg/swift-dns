import Foundation
import Testing

@testable import DNS

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

    // MARK: - Bug 3: Suffix Compression Tests

    @Test("compresses suffix when writing longer domain after shorter")
    func suffixCompressionLongerAfterShorter() throws {
        // Bug 3: When writing "google.com" then "mail.google.com", the suffix
        // "google.com" should be compressed using a pointer to the first occurrence.
        //
        // Currently, the compressor only matches exact sequences, not suffixes.

        var compressor = DNSPacketCompressor()

        // First write: "google.com"
        try compressor.write(DNSLabels(labels: ["google", "com"]))

        // Second write: "mail.google.com" - should write "mail" then pointer to "google.com"
        try compressor.write(DNSLabels(labels: ["mail", "google", "com"]))

        // Expected output:
        // Offset 0x00: 06 "google" 03 "com" 00  (11 bytes)
        // Offset 0x0B: 04 "mail" C0 00          (7 bytes - "mail" + pointer to offset 0)
        //
        // Without suffix compression (BUG), it would write:
        // Offset 0x00: 06 "google" 03 "com" 00  (11 bytes)
        // Offset 0x0B: 04 "mail" 06 "google" 03 "com" 00  (16 bytes - no compression)

        let expected: [UInt8] = [
            0x06,  // length 6
            0x67, 0x6F, 0x6F, 0x67, 0x6C, 0x65,  // "google"
            0x03,  // length 3
            0x63, 0x6F, 0x6D,  // "com"
            0x00,  // null terminator
            0x04,  // length 4
            0x6D, 0x61, 0x69, 0x6C,  // "mail"
            0xC0, 0x00,  // pointer to offset 0
        ]

        #expect(
            compressor.data == Data(expected),
            "Suffix 'google.com' should be compressed. Got: \(compressor.data.map { String(format: "%02X", $0) }.joined(separator: " "))"
        )

        // Also verify the compressed version is smaller
        var uncompressedWriter = ByteBufferWriter()
        try uncompressedWriter.write(DNSLabels(labels: ["google", "com"]))
        try uncompressedWriter.write(DNSLabels(labels: ["mail", "google", "com"]))

        // The compressed output should be smaller than uncompressed
        #expect(
            compressor.data.count < uncompressedWriter.data.count,
            "Compressed (\(compressor.data.count) bytes) should be smaller than uncompressed (\(uncompressedWriter.data.count) bytes)"
        )
    }

    @Test("compresses common suffix across multiple domains")
    func suffixCompressionMultipleDomains() throws {
        // Write three domains that share the ".com" suffix:
        // - "example.com"
        // - "google.com"
        // - "test.com"
        //
        // At minimum, ".com" should be compressed for the second and third writes.

        var compressor = DNSPacketCompressor()

        try compressor.write(DNSLabels(labels: ["example", "com"]))
        try compressor.write(DNSLabels(labels: ["google", "com"]))
        try compressor.write(DNSLabels(labels: ["test", "com"]))

        // Calculate the uncompressed size for comparison
        var uncompressedWriter = ByteBufferWriter()
        try uncompressedWriter.write(DNSLabels(labels: ["example", "com"]))
        try uncompressedWriter.write(DNSLabels(labels: ["google", "com"]))
        try uncompressedWriter.write(DNSLabels(labels: ["test", "com"]))

        // Compressed should be smaller because ".com" can be reused
        // Uncompressed: 14 + 12 + 10 = 36 bytes
        // Compressed: 14 + (7 + 2) + (5 + 2) = 30 bytes (saving 6 bytes)
        #expect(
            compressor.data.count < uncompressedWriter.data.count,
            "Should compress shared suffix. Compressed: \(compressor.data.count), Uncompressed: \(uncompressedWriter.data.count)"
        )
    }

}
