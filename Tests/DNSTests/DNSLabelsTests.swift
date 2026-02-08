//
//  DNSLabelsTests.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation
import Testing

@testable import DNS

@Suite
struct DNSLabelsTests {

    // MARK: - Label Compression Seek-Back

    @Test("correctly positions buffer after decoding labels with uncompressed prefix and compression pointer")
    func seekBackWithUncompressedPrefix() throws {
        // This test verifies that after decoding a label sequence with an uncompressed
        // prefix followed by a compression pointer, the buffer position is correctly
        // set to just after the compression pointer bytes.
        //
        // Structure:
        // Offset 0x00: 06 "google" 03 "com" 00  (google.com - 12 bytes total)
        // Offset 0x0C: 04 "mail" C0 0C          (mail + pointer to 0x00)
        // Offset 0x13: <next data>
        //
        // When decoding from offset 0x0C, the result should be ["mail", "google", "com"]
        // and the buffer position should be at 0x13 (after the 2-byte pointer), not 0x0E.

        var data = Data()

        // Offset 0x00-0x0B: "google.com" (12 bytes)
        data.append(contentsOf: [0x06])  // length of "google"
        data.append(contentsOf: "google".data(using: .ascii)!)
        data.append(contentsOf: [0x03])  // length of "com"
        data.append(contentsOf: "com".data(using: .ascii)!)
        data.append(contentsOf: [0x00])  // null terminator

        // Offset 0x0C-0x12: "mail" + pointer to 0x00 (7 bytes)
        data.append(contentsOf: [0x04])  // length of "mail"
        data.append(contentsOf: "mail".data(using: .ascii)!)
        data.append(contentsOf: [0xC0, 0x00])  // pointer to offset 0

        // Offset 0x13: marker byte to verify position
        data.append(contentsOf: [0xAA])  // sentinel value

        // Start reading from offset 0x0C (the "mail" + pointer sequence)
        var buffer: any ByteBufferReading = ByteBufferReader(data)
        try buffer.seek(0x0C)

        let labels = try DNSLabels.decode(from: &buffer)

        // Verify the decoded labels
        #expect(labels.labels == ["mail", "google", "com"])

        // Buffer should be at position 0x13 (right after the pointer)
        #expect(
            buffer.currentIndex == 0x13,
            "Buffer position should be after the compression pointer (0x13), not \(buffer.currentIndex)"
        )

        // Extra verification: reading the next byte should give us the sentinel
        let nextByte = try buffer.readByte()
        #expect(nextByte == 0xAA, "Next byte should be sentinel 0xAA")
    }

    @Test("correctly positions buffer when compression pointer is at start")
    func seekBackWithPointerAtStart() throws {
        // When the compression pointer is at the start (no uncompressed prefix),
        // the seek-back should still work correctly.

        var data = Data()

        // Offset 0x00-0x0B: "google.com" (12 bytes)
        data.append(contentsOf: [0x06])
        data.append(contentsOf: "google".data(using: .ascii)!)
        data.append(contentsOf: [0x03])
        data.append(contentsOf: "com".data(using: .ascii)!)
        data.append(contentsOf: [0x00])

        // Offset 0x0C-0x0D: pointer to 0x00 (2 bytes only, no prefix)
        data.append(contentsOf: [0xC0, 0x00])

        // Offset 0x0E: sentinel
        data.append(contentsOf: [0xBB])

        var buffer: any ByteBufferReading = ByteBufferReader(data)
        try buffer.seek(0x0C)

        let labels = try DNSLabels.decode(from: &buffer)

        #expect(labels.labels == ["google", "com"])
        #expect(buffer.currentIndex == 0x0E, "Buffer should be at 0x0E after pointer")

        let nextByte = try buffer.readByte()
        #expect(nextByte == 0xBB)
    }

}
