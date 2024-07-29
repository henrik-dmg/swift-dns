//
//  DNSRecordDecoder.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

struct DNSRecordDecoder {}

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
                address: IPv4Address(fragments: Array(customData))
            )
        case .AAAA:
            return DNSAAAARecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                address: try IPv6Address(fragments: Array(customData))
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
        case .TXT:
            let lengthOfString = customData[0]
            let contentData = customData.dropFirst()
            guard let content = String(data: contentData, encoding: .ascii), content.count == Int(lengthOfString) else {
                throw DecoderError.cantConvertToString(bytes: contentData)
            }

            return DNSTXTRecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                content: content
            )
        case .SOA, .unknown:
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
