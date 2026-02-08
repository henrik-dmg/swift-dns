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
        case .a:
            return ARecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                address: IPv4Address(fragments: Array(customData))
            )
        case .aaaa:
            return AAAARecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                address: try IPv6Address(fragments: Array(customData))
            )
        case .ns:
            // Decode the nameserver domain from the record's RDATA (customData),
            // not from the main byteBuffer which has already advanced past the record.
            var subBuffer: any ByteBufferReading = ByteBufferReader(customData)
            return NSRecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                lengthOfCustomData: lengthOfCustomData,
                paylodLabels: try DNSLabels.decode(from: &subBuffer)
            )
        case .cname:
            // Decode the canonical name from the record's RDATA (customData).
            var subBuffer: any ByteBufferReading = ByteBufferReader(customData)
            return CNAMERecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                lengthOfCustomData: lengthOfCustomData,
                paylodLabels: try DNSLabels.decode(from: &subBuffer)
            )
        case .mx:
            // Decode priority and mail server domain from the record's RDATA (customData).
            var subBuffer: any ByteBufferReading = ByteBufferReader(customData)
            return MXRecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                lengthOfCustomData: lengthOfCustomData,
                priority: try subBuffer.readUInt16(),
                paylodLabels: try DNSLabels.decode(from: &subBuffer)
            )
        case .txt:
            let lengthOfString = customData[0]
            let contentData = customData.dropFirst()
            guard let content = String(data: contentData, encoding: .ascii), content.count == Int(lengthOfString) else {
                throw DecoderError.cantConvertToString(bytes: contentData)
            }

            return TXTRecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                content: content
            )
        case .soa, .unknown:
            return UnknownRecord(
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
