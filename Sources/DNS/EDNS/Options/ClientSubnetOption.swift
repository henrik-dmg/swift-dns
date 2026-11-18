//
//  ClientSubnetOption.swift
//  swift-dns
//

import Foundation

/// Represents the Client Subnet EDNS option (RFC 7871).
///
/// This option allows a DNS resolver to include information about the
/// network from which the query originated, enabling content delivery
/// networks to provide geographically appropriate responses.
public struct ClientSubnetOption: EDNSOption, EDNSOptionEncodable {

    // MARK: - Properties

    public let code: EDNSOptionCode = .clientSubnet

    public var dataLength: UInt16 {
        // family (2) + sourcePrefixLength (1) + scopePrefixLength (1) + address bytes
        UInt16(4 + address.count)
    }

    /// The address family (1 = IPv4, 2 = IPv6).
    public let family: UInt16

    /// The leftmost number of significant bits of the address in the query.
    public let sourcePrefixLength: UInt8

    /// The leftmost number of significant bits of the address in the response.
    public let scopePrefixLength: UInt8

    /// The address bytes, truncated to the source prefix length.
    public let address: Data

    // MARK: - Init

    /// Creates a new Client Subnet option.
    ///
    /// - Parameters:
    ///   - family: The address family (1 = IPv4, 2 = IPv6).
    ///   - sourcePrefixLength: The number of significant bits in the source address.
    ///   - scopePrefixLength: The number of significant bits in the scope address.
    ///   - address: The address bytes, truncated to the source prefix length.
    public init(family: UInt16, sourcePrefixLength: UInt8, scopePrefixLength: UInt8, address: Data) {
        self.family = family
        self.sourcePrefixLength = sourcePrefixLength
        self.scopePrefixLength = scopePrefixLength
        self.address = address
    }

    // MARK: - Encoding

    func encodeOptionData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        buffer.write(family)
        buffer.write(sourcePrefixLength)
        buffer.write(scopePrefixLength)
        buffer.write(address)
    }

}
