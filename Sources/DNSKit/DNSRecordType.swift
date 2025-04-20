//
//  DNSRecordType.swift
//  swift-dns
//
//  Created by Henrik Panhans on 26.07.24.
//

// swift-format-ignore: AlwaysUseLowerCamelCase

/// Represents the type of a DNS resource record.
///
/// Each record type has a specific numeric value assigned by IANA and serves a particular purpose in the DNS system.
public enum DNSRecordType: Sendable, Equatable, CaseIterable {

    /// Represents an unknown or unsupported record type.
    ///
    /// The associated UInt16 value contains the raw numeric type code from the DNS message.
    case unknown(UInt16 = 0)

    /// Address record (Type 1)
    /// Maps a hostname to an IPv4 address.
    case A

    /// IPv6 Address record (Type 28)
    /// Maps a hostname to an IPv6 address.
    case AAAA

    /// Name Server record (Type 2)
    /// Delegates a DNS zone to use the given authoritative name servers.
    case NS

    /// Canonical Name record (Type 5)
    /// Maps an alias name to the true or canonical name.
    case CNAME

    /// Mail Exchange record (Type 15)
    /// Maps a domain name to a list of message transfer agents for that domain.
    case MX

    /// Start of Authority record (Type 6)
    /// Specifies authoritative information about a DNS zone.
    case SOA

    /// Text record (Type 16)
    /// Contains arbitrary text data, often used for various purposes like SPF, DKIM, etc.
    case TXT

    /// Returns all possible record types, including the unknown case.
    public static var allCases: [DNSRecordType] {
        [.unknown(0), .A, .AAAA, .NS, .CNAME, .MX, .SOA, .TXT]
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
        case 1: .A
        case 28: .AAAA
        case 5: .CNAME
        case 15: .MX
        case 2: .NS
        case 6: .SOA
        case 16: .TXT
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
            case .unknown(let integer): integer
            case .A: 1
            case .AAAA: 28
            case .CNAME: 5
            case .MX: 15
            case .NS: 2
            case .SOA: 6
            case .TXT: 16
            }
        byteBuffer.write(integerToEncode)
    }

}
