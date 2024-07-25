//
//  DNSRecordDecoder.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

struct DNSRecordDecoder {

    enum DecodingError: LocalizedError {
        case cantReadRecordType
    }

    enum DNSRecordType: UInt16 {
        case unknown
        case A = 1
    }

}

extension DNSRecordDecoder: DNSPacketDecodable {

    static func decode(from byteBuffer: inout ByteBufferReader) throws -> any DNSRecord {
        let labels = try DNSLabels.decode(from: &byteBuffer)
        let recordType = DNSRecordType(rawValue: try byteBuffer.readUInt16())
        let recordClass = try byteBuffer.readUInt16()
        let timeToLive = try byteBuffer.readUInt32()
        let length = try byteBuffer.readUInt16()

        switch recordType {
        case .unknown:
            return DNSUnknownRecord(
                labels: labels,
                recordType: recordType!.rawValue,
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
