//
//  DNSRecordDecoder.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

struct DNSRecordDecoder {

    enum DecodingError: LocalizedError {
        case cantReadRecordType(rawValue: UInt16)
    }

}

extension DNSRecordDecoder: DNSPacketDecodable {

    static func decode(from byteBuffer: inout ByteBufferReading) throws -> any DNSRecord {
        let labels = try DNSLabels.decode(from: &byteBuffer)
        let recordType = try DNSRecordType.decode(from: &byteBuffer)
        let recordClass = try byteBuffer.readUInt16()
        let timeToLive = try byteBuffer.readUInt32()
        let lengthOfCustomData = try byteBuffer.readUInt16()

        let customData = try byteBuffer.readBytes(Int(lengthOfCustomData))

        switch recordType {
        case .A:
            return DNSARecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                lengthOfCustomData: lengthOfCustomData,
                ipFragments: Array(customData)
            )
        case .AAAA:
            return DNSAAAARecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                lengthOfCustomData: lengthOfCustomData,
                ipFragments: Array(customData)
            )
        case .NS:
            return DNSNSRecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                lengthOfCustomData: lengthOfCustomData,
                paylodLabels: try DNSLabels.decode(from: &byteBuffer)
            )
        case .CNAME:
            return DNSCNAMERecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                lengthOfCustomData: lengthOfCustomData,
                paylodLabels: try DNSLabels.decode(from: &byteBuffer)
            )
        case .MX:
            return DNSMXRecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                lengthOfCustomData: lengthOfCustomData,
                priority: try byteBuffer.readUInt16(),
                paylodLabels: try DNSLabels.decode(from: &byteBuffer)
            )
        case .unknown:
            return DNSUnknownRecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                lengthOfCustomData: lengthOfCustomData,
                bytes: customData
            )
        }
    }

}
