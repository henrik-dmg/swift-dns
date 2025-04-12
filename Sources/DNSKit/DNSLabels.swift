//
//  DNSLabels.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

/// Represents a domain name in DNS message format.
/// DNS labels are used to represent domain names in a hierarchical structure,
/// where each label is a component of the domain name (e.g., "www.example.com" becomes ["www", "example", "com"]).
/// This structure also handles DNS message compression, which uses jump pointers to avoid repeating domain names.
public struct DNSLabels: Equatable, Sendable {

    // MARK: - Properties

    /// The maximum number of compression jumps allowed in a DNS message.
    /// This prevents infinite loops in case of malformed messages with circular references.
    static let maxAllowedJumps = 5

    /// The bit pattern that indicates a compression jump in DNS message format.
    /// When the two most significant bits of a length byte are set (0xC0), it indicates a jump pointer.
    static let jumpDirective: UInt8 = 0xC0

    /// The array of string labels that make up the domain name.
    /// Each string represents a component of the domain name in order from left to right.
    public var labels: [String]

}

// MARK: - Decoding

extension DNSLabels: DNSPacketDecodable {

    /// Decodes DNS labels from a byte buffer, handling both uncompressed and compressed formats.
    /// DNS message compression is supported through jump pointers, which allow referencing
    /// previously used domain names to reduce message size.
    ///
    /// The decoding process:
    /// 1. Reads each label length byte
    /// 2. If the length byte indicates a jump (0xC0), follows the jump pointer
    /// 3. Otherwise, reads the specified number of bytes as an ASCII label
    /// 4. Continues until a zero-length label is encountered (end of domain name)
    ///
    /// - Parameter byteBuffer: The buffer containing the DNS message data
    /// - Returns: A DNSLabels instance containing the decoded domain name
    /// - Throws:
    ///   - DecoderError.maximumNumberOfJumpsReached if too many jumps are encountered
    ///   - DecoderError.cantConvertToString if a label cannot be converted to ASCII
    ///   - DecoderError.noLabelsDecoded if no valid labels are found
    static func decode(from byteBuffer: inout ByteBufferReading) throws -> DNSLabels {
        var labels: [String] = []

        // Store the initial position for handling jumps
        let initialPosition = byteBuffer.currentIndex
        var hasJumped = false
        var jumpsPerformed = 0

        while true {
            // Prevent infinite loops from circular references
            guard jumpsPerformed <= DNSLabels.maxAllowedJumps else { throw DecoderError.maximumNumberOfJumpsReached }

            // Read the length of the next label
            let labelLength = try byteBuffer.readByte()
            guard labelLength != 0 else {
                break  // Zero length indicates end of domain name
            }

            // Check for compression jump
            if (labelLength & Self.jumpDirective) == Self.jumpDirective {
                hasJumped = true
                // Calculate jump destination from the two bytes
                let jumpDestinationByte = try byteBuffer.readByte()
                let labelOffset = UInt16(labelLength ^ Self.jumpDirective) << 8 + UInt16(jumpDestinationByte)
                jumpsPerformed += 1
                try byteBuffer.seek(Int(labelOffset))
            } else {
                // Read uncompressed label
                let labelBytes = try byteBuffer.readBytes(Int(labelLength))
                guard let label = String(data: labelBytes, encoding: .ascii) else {
                    throw DecoderError.cantConvertToString(bytes: labelBytes)
                }
                labels.append(label)
            }
        }

        // If we followed a jump, return to the position after the jump pointer
        if hasJumped {
            try byteBuffer.seek(initialPosition + 2)  // +2 because if we jumped, we need to skip past the two jump directive bytes
        }

        // Ensure we decoded at least one label
        guard !labels.isEmpty else { throw DecoderError.noLabelsDecoded }

        return DNSLabels(labels: labels)
    }

}
