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

}

extension DNSRecordDecoder: DNSPacketDecodable {

    static func decode(from byteBuffer: inout ByteBufferReader) throws -> any DNSRecord {
        let labels = try DNSLabels.decode(from: &byteBuffer)
        let recordType = DNSRecordType(rawValue: try byteBuffer.readUInt16())
        let recordClass = try byteBuffer.readUInt16()
        let timeToLive = try byteBuffer.readUInt32()
        let length = try byteBuffer.readUInt16()

        let customData = try byteBuffer.readBytes(Int(length))

        switch recordType {
        case .unknown:
            return DNSUnknownRecord(
                labels: labels,
                recordType: recordType!,
                recordClass: recordClass,
                timeToLive: timeToLive,
                bytes: customData
            )
        case .A:
            return DNSARecord(
                labels: labels,
                recordType: recordType!,
                recordClass: recordClass,
                timeToLive: timeToLive,
                ipFragments: Array(customData)
            )
        case .none:
            throw DecodingError.cantReadRecordType
        }
    }

}
