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

        // Save the position where RDATA starts for records that need full packet access
        let rdataStartIndex = byteBuffer.currentIndex

        let customData = try byteBuffer.readBytes(Int(lengthOfCustomData))

        switch recordType {
        case .a:
            // Decodes an IPv4 A record
            return ARecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                address: IPv4Address(fragments: Array(customData))
            )
        case .aaaa:
            // Decodes an IPv6 AAAA record
            return AAAARecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                address: try IPv6Address(fragments: Array(customData))
            )
        case .ns:
            // Decode the nameserver domain from the RDATA.
            // Use the full packet buffer to support compression pointers.
            var nsBuffer: any ByteBufferReading = ByteBufferReader(byteBuffer.data)
            nsBuffer.currentIndex = rdataStartIndex
            return NSRecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                lengthOfCustomData: lengthOfCustomData,
                paylodLabels: try DNSLabels.decode(from: &nsBuffer)
            )
        case .cname:
            // Decode the canonical name from the RDATA.
            // Use the full packet buffer to support compression pointers.
            var cnameBuffer: any ByteBufferReading = ByteBufferReader(byteBuffer.data)
            cnameBuffer.currentIndex = rdataStartIndex
            return CNAMERecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                lengthOfCustomData: lengthOfCustomData,
                paylodLabels: try DNSLabels.decode(from: &cnameBuffer)
            )
        case .mx:
            // Decode priority and mail server domain from the RDATA.
            // Use the full packet buffer to support compression pointers.
            var mxBuffer: any ByteBufferReading = ByteBufferReader(byteBuffer.data)
            mxBuffer.currentIndex = rdataStartIndex
            return MXRecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                lengthOfCustomData: lengthOfCustomData,
                priority: try mxBuffer.readUInt16(),
                paylodLabels: try DNSLabels.decode(from: &mxBuffer)
            )
        case .soa:
            // Decode SOA record fields from the RDATA.
            // Use the full packet buffer to support compression pointers.
            var soaBuffer: any ByteBufferReading = ByteBufferReader(byteBuffer.data)
            soaBuffer.currentIndex = rdataStartIndex
            return SOARecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                lengthOfCustomData: lengthOfCustomData,
                primaryNameServer: try DNSLabels.decode(from: &soaBuffer),
                responsibleMailbox: try DNSLabels.decode(from: &soaBuffer),
                serial: try soaBuffer.readUInt32(),
                refresh: try soaBuffer.readUInt32(),
                retry: try soaBuffer.readUInt32(),
                expire: try soaBuffer.readUInt32(),
                minimum: try soaBuffer.readUInt32()
            )
        case .txt:
            // Decodes an arbitrary TXT record
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
        case .unknown:
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
