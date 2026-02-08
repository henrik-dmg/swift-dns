//
//  IPv4Address.swift
//  swift-dns
//
//  Created by Henrik Panhans on 26.07.24.
//

/// Represents an IPv4 address in the DNS system.
///
/// IPv4 addresses are 32-bit addresses typically represented in dotted-decimal notation
/// (e.g., 192.168.1.1). Each octet is stored as a separate byte in the fragments array.
public struct IPv4Address: IPAddress {

    // MARK: - Properties

    /// The four octets that make up the IPv4 address.
    ///
    /// Each element in the array represents one octet of the address.
    public let fragments: [UInt8]

    // MARK: - Init

    /// Internal initializer that creates an IPv4 address from an array of octets.
    ///
    /// - Parameter fragments: An array of four bytes representing the IPv4 address
    init(fragments: [UInt8]) { self.fragments = fragments }

    /// Creates a new IPv4 address from four octets.
    ///
    /// - Parameters:
    ///   - octet1: The first octet of the IPv4 address
    ///   - octet2: The second octet of the IPv4 address
    ///   - octet3: The third octet of the IPv4 address
    ///   - octet4: The fourth octet of the IPv4 address
    public init(_ octet1: UInt8, _ octet2: UInt8, _ octet3: UInt8, _ octet4: UInt8) {
        self.init(fragments: [octet1, octet2, octet3, octet4])
    }

    // MARK: - Formatting

    /// Returns a string representation of the IPv4 address in dotted-decimal notation.
    ///
    /// For example, the address [192, 168, 1, 1] will be formatted as "192.168.1.1".
    ///
    /// - Returns: A string representation of the IPv4 address
    public func formattedAddress() -> String { fragments.map { "\($0)" }.joined(separator: ".") }

}

// MARK: - Encoding

extension IPv4Address: DNSPacketEncodable {

    /// Encodes the IPv4 address into a byte buffer for DNS message transmission.
    ///
    /// The address is written as four consecutive bytes.
    ///
    /// - Parameter byteBuffer: The buffer to write the encoded data to
    /// - Throws: An error if the buffer cannot be written to
    func encode(into byteBuffer: inout any ByteBufferWriting) throws { byteBuffer.write(fragments) }

}

// MARK: - CustomDebugStringConvertible

extension IPv4Address: CustomDebugStringConvertible {

    /// Returns a debug description of the IPv4 address.
    ///
    /// The format is "IPv4(x.x.x.x)" where x.x.x.x is the dotted-decimal representation.
    public var debugDescription: String { "IPv4(\(formattedAddress()))" }

}
