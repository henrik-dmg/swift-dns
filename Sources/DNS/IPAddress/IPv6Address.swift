//
//  IPv6Address.swift
//  swift-dns
//
//  Created by Henrik Panhans on 26.07.24.
//

import Foundation

/// Represents an IPv6 address in the DNS system.
///
/// IPv6 addresses are 128-bit addresses typically represented in hexadecimal notation
/// with compression (e.g., 2001:db8::1). The address is stored as eight 16-bit fragments.
public struct IPv6Address: IPAddress {

    // MARK: - Properties

    /// The eight 16-bit fragments that make up the IPv6 address.
    ///
    /// Each element in the array represents one 16-bit segment of the address.
    public let fragments: [UInt16]

    // MARK: - Init

    /// Internal initializer that creates an IPv6 address from an array of bytes.
    ///
    /// The bytes are combined into 16-bit fragments.
    ///
    /// - Parameter fragments: An array of 16 bytes representing the IPv6 address
    /// - Throws: DecoderError.invalidIPv6Address if the byte array does not contain exactly 16 bytes
    init(fragments: [UInt8]) throws {
        guard fragments.count == 16 else {
            throw DecoderError.invalidIPv6Address(bytes: Data(fragments))
        }
        var joinedFragments: [UInt16] = []
        for i in 0 ..< fragments.count where i % 2 == 0 {
            joinedFragments.append(join(fragments[i], fragments[i + 1]))
        }
        self.fragments = joinedFragments
    }

    /// Creates a new IPv6 address from eight 16-bit segments.
    ///
    /// - Parameters:
    ///   - octet1: The first 16-bit segment of the IPv6 address
    ///   - octet2: The second 16-bit segment of the IPv6 address
    ///   - octet3: The third 16-bit segment of the IPv6 address
    ///   - octet4: The fourth 16-bit segment of the IPv6 address
    ///   - octet5: The fifth 16-bit segment of the IPv6 address
    ///   - octet6: The sixth 16-bit segment of the IPv6 address
    ///   - octet7: The seventh 16-bit segment of the IPv6 address
    ///   - octet8: The eighth 16-bit segment of the IPv6 address
    public init(
        _ octet1: UInt16,
        _ octet2: UInt16,
        _ octet3: UInt16,
        _ octet4: UInt16,
        _ octet5: UInt16,
        _ octet6: UInt16,
        _ octet7: UInt16,
        _ octet8: UInt16
    ) {
        fragments = [octet1, octet2, octet3, octet4, octet5, octet6, octet7, octet8]
    }

    // MARK: - Formatting

    /// Returns a string representation of the IPv6 address in hexadecimal notation with compression.
    ///
    /// The address is formatted according to RFC 5952, which includes:
    /// - Leading zeros in each 16-bit segment are omitted
    /// - The longest sequence of consecutive zero segments is replaced with "::"
    /// - Lowercase letters are used for hexadecimal digits
    ///
    /// - Returns: A string representation of the IPv6 address
    public func formattedAddress() -> String {
        var formattedAddress = ""
        let stringFragments = fragments.map { String(format: "%02X", $0) }
        for fragment in stringFragments {
            if fragment != "00" {
                if formattedAddress.last != ":" && !formattedAddress.isEmpty {
                    formattedAddress.append(":")
                }
                formattedAddress += fragment
            } else {
                if formattedAddress.hasSuffix("::") {
                    continue
                } else {
                    formattedAddress += "::"
                }
            }
        }
        return formattedAddress
    }

}

// MARK: - Encoding

extension IPv6Address: DNSPacketEncodable {

    /// Encodes the IPv6 address into a byte buffer for DNS message transmission.
    ///
    /// The address is written as eight consecutive 16-bit values in network byte order.
    ///
    /// - Parameter byteBuffer: The buffer to write the encoded data to
    /// - Throws: An error if the buffer cannot be written to
    func encode(into byteBuffer: inout any ByteBufferWriting) throws {
        for fragment in self.fragments { byteBuffer.write(fragment) }
    }

}

// MARK: - CustomDebugStringConvertible

extension IPv6Address: CustomDebugStringConvertible {

    /// Returns a debug description of the IPv6 address.
    ///
    /// The format is "IPv6(x:x:x:x:x:x:x:x)" where x:x:x:x:x:x:x:x is the hexadecimal representation.
    public var debugDescription: String { "IPv6(\(formattedAddress()))" }

}
