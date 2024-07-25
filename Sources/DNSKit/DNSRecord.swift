//
//  DNSRecord.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

public protocol DNSRecord {}

struct DNSRecordDecoder {

    enum DecodingError: LocalizedError {
        case cantReadRecordType
    }

    static func decode(from byteBuffer: inout ByteBuffer) throws -> any DNSRecord {
        let labels = try DNSLabels.decode(from: &byteBuffer)
        let recordType = DNSRecordType(rawValue: try byteBuffer.readUInt16())
        let recordClass = try byteBuffer.readUInt16()
        let timeToLive = try byteBuffer.readUInt32()
        let length = try byteBuffer.readUInt16()

        switch recordType {
        case .unknown:
            return DNSUnknownRecord(
                labels: labels,
                recordType: recordType!,
                recordClass: recordClass,
                timeToLive: timeToLive,
                length: length
            )
        case .A:
            let ipFragments = try byteBuffer.readBytes(Int(length))
            return DNSARecord(labels: labels, recordClass: recordClass, timeToLive: timeToLive, ipFragments: Array(ipFragments))
        case .none:
            throw DecodingError.cantReadRecordType
        }
    }

}

public struct DNSUnknownRecord: DNSRecord {
    public let labels: DNSLabels
    public let recordType: DNSRecordType
    public let recordClass: UInt16
    public let timeToLive: UInt32
    public let length: UInt16
}

public struct DNSARecord: DNSRecord {
    public let labels: DNSLabels
    public let recordClass: UInt16
    public let timeToLive: UInt32
    public let ipFragments: [UInt8]
}

public enum DNSRecordType: UInt16 {
    case unknown
    case A = 1
}
