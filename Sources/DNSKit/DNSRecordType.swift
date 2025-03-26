//
//  DNSRecordType.swift
//  swift-dns
//
//  Created by Henrik Panhans on 26.07.24.
//

// swift-format-ignore: AlwaysUseLowerCamelCase
public enum DNSRecordType: Sendable, Equatable, CaseIterable {

    case unknown(UInt16)
    case A
    case AAAA
    case NS
    case CNAME
    case MX
    case SOA
    case TXT

    public static var allCases: [DNSRecordType] {
        [.unknown(0), .A, .AAAA, .NS, .CNAME, .MX, .SOA, .TXT]
    }

}

// MARK: - Decoding

extension DNSRecordType: DNSPacketDecodable {

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
