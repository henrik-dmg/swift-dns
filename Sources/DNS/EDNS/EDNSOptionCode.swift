//
//  EDNSOptionCode.swift
//  swift-dns
//

/// Represents the option code for an EDNS option.
///
/// Option codes are assigned by IANA and identify the type of EDNS option
/// carried in the RDATA of an OPT pseudo-record (RFC 6891).
public enum EDNSOptionCode: Sendable, Equatable {

    /// Name Server Identifier (3, RFC 5001)
    case nsid

    /// Client Subnet (8, RFC 7871)
    case clientSubnet

    /// DNS Cookie (10, RFC 7873)
    case cookie

    /// Padding (12, RFC 7830)
    case padding

    /// Extended DNS Error (15, RFC 8914)
    case extendedDNSError

    /// An unrecognized or unsupported option code.
    case unknown(UInt16)

    /// The raw numeric option code value.
    public var rawValue: UInt16 {
        switch self {
        case .nsid: 3
        case .clientSubnet: 8
        case .cookie: 10
        case .padding: 12
        case .extendedDNSError: 15
        case .unknown(let value): value
        }
    }

    /// Creates an option code from its raw numeric value.
    public init(rawValue: UInt16) {
        self =
            switch rawValue {
            case 3: .nsid
            case 8: .clientSubnet
            case 10: .cookie
            case 12: .padding
            case 15: .extendedDNSError
            default: .unknown(rawValue)
            }
    }

}

// MARK: - Decoding

extension EDNSOptionCode: DNSPacketDecodable {

    static func decode(from buffer: inout ByteBufferReading) throws -> EDNSOptionCode {
        let rawValue = try buffer.readUInt16()
        return EDNSOptionCode(rawValue: rawValue)
    }

}

// MARK: - Encoding

extension EDNSOptionCode: DNSPacketEncodable {

    func encode(into buffer: inout ByteBufferWriting) throws {
        buffer.write(rawValue)
    }

}
