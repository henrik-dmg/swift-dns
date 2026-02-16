//
//  DNSRecordType.swift
//  swift-dns
//
//  Created by Henrik Panhans on 26.07.24.
//

/// Represents the type of a DNS resource record.
///
/// Each record type has a specific numeric value assigned by IANA and serves a particular purpose in the DNS system.
public enum DNSRecordType: Sendable, Equatable, CaseIterable {

    /// Represents an unknown or unsupported record type.
    ///
    /// The associated UInt16 value contains the raw numeric type code from the DNS message.
    case unknown(UInt16)

    /// Address record (Type 1)
    /// Maps a hostname to an IPv4 address.
    case a

    /// IPv6 Address record (Type 28)
    /// Maps a hostname to an IPv6 address.
    case aaaa

    /// Name Server record (Type 2)
    /// Delegates a DNS zone to use the given authoritative name servers.
    case ns

    /// Canonical Name record (Type 5)
    /// Maps an alias name to the true or canonical name.
    case cname

    /// Mail Exchange record (Type 15)
    /// Maps a domain name to a list of message transfer agents for that domain.
    case mx

    /// Start of Authority record (Type 6)
    /// Specifies authoritative information about a DNS zone.
    case soa

    /// Text record (Type 16)
    /// Contains arbitrary text data, often used for various purposes like SPF, DKIM, etc.
    case txt

    /// Pointer record (Type 12)
    /// Maps an IP address to a domain name (reverse DNS lookup).
    case ptr

    /// Service Locator record (Type 33)
    /// Specifies the location of services (host and port) for a domain.
    case srv

    /// OPT pseudo-record (Type 41)
    /// Used by EDNS (Extension Mechanisms for DNS, RFC 6891) to signal extended capabilities.
    case opt

    /// Returns all possible record types, including the unknown case.
    public static var allCases: [DNSRecordType] {
        [.unknown(0), .a, .aaaa, .ns, .cname, .mx, .soa, .txt, .ptr, .srv, .opt]
    }

}

// MARK: - Decoding

extension DNSRecordType: DNSPacketDecodable {

    /// Decodes a DNS record type from a byte buffer.
    ///
    /// The numeric values are defined in the DNS protocol specification.
    ///
    /// - Parameter byteBuffer: The buffer containing the DNS message data
    /// - Returns: The decoded DNS record type
    /// - Throws: An error if the buffer cannot be read
    static func decode(from byteBuffer: inout any ByteBufferReading) throws -> Self {
        let integer = try byteBuffer.readUInt16()
        return switch integer {
        case 1: .a
        case 28: .aaaa
        case 5: .cname
        case 15: .mx
        case 2: .ns
        case 6: .soa
        case 16: .txt
        case 12: .ptr
        case 33: .srv
        case 41: .opt
        default: .unknown(integer)
        }
    }

}

// MARK: - Encoding

extension DNSRecordType: DNSPacketEncodable {

    /// Encodes the DNS record type into a byte buffer.
    ///
    /// The numeric values are defined in the DNS protocol specification.
    ///
    /// - Parameter byteBuffer: The buffer to write the encoded data to
    /// - Throws: An error if the buffer cannot be written to
    func encode(into byteBuffer: inout any ByteBufferWriting) throws {
        let integerToEncode: UInt16 =
            switch self {
            case .a: 1
            case .aaaa: 28
            case .cname: 5
            case .mx: 15
            case .ns: 2
            case .soa: 6
            case .txt: 16
            case .ptr: 12
            case .srv: 33
            case .opt: 41
            case .unknown(let integer): integer
            }
        byteBuffer.write(integerToEncode)
    }

}
