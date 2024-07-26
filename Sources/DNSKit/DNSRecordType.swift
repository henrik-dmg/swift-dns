//
//  DNSRecordType.swift
//  swift-dns
//
//  Created by Henrik Panhans on 26.07.24.
//

public enum DNSRecordType: Sendable, Equatable {

    case unknown(UInt16)
    case A(UInt16)
    case AAAA(UInt16)
    case NS(UInt16)
    case CNAME(UInt16)
    case MX(UInt16)

    var rawValue: UInt16 {
        switch self {
        case .unknown(let uInt16), .A(let uInt16), .NS(let uInt16), .CNAME(let uInt16), .MX(let uInt16), .AAAA(let uInt16):
            return uInt16
        }
    }

}

// MARK: - Decoding

extension DNSRecordType: DNSPacketDecodable {

    static func decode(from byteBuffer: inout any ByteBufferReading) throws -> Self {
        let integer = try byteBuffer.readUInt16()
        switch integer {
        case 1: return .A(integer)
        case 2: return .NS(integer)
        case 5: return .CNAME(integer)
        case 15: return .MX(integer)
        case 28: return .AAAA(integer)
        default:
            return .unknown(integer)
        }
    }

}

// MARK: - Encoding

extension DNSRecordType: DNSPacketEncodable {

    func encode(into byteBuffer: inout any ByteBufferWriting) throws {
        byteBuffer.write(rawValue)
    }

}
