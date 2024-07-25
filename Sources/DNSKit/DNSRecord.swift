//
//  DNSRecord.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

protocol DNSRecord {}

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

struct DNSUnknownRecord: DNSRecord {
    let labels: DNSLabels
    let recordType: DNSRecordType
    let recordClass: UInt16
    let timeToLive: UInt32
    let length: UInt16
}

struct DNSARecord: DNSRecord {
    let labels: DNSLabels
    let recordClass: UInt16
    let timeToLive: UInt32
    let ipFragments: [UInt8]
}

public enum DNSRecordType: UInt16 {
    case unknown
    case A = 1
}
