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
            guard lengthOfCustomData == 4 else {
                throw DecoderError.rdataLengthMismatch(expected: 4, actual: Int(lengthOfCustomData))
            }
            return ARecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                address: IPv4Address(fragments: Array(customData))
            )
        case .aaaa:
            // Decodes an IPv6 AAAA record
            guard lengthOfCustomData == 16 else {
                throw DecoderError.rdataLengthMismatch(expected: 16, actual: Int(lengthOfCustomData))
            }
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
            let payloadLabels = try DNSLabels.decode(from: &nsBuffer)
            let bytesRead = nsBuffer.currentIndex - rdataStartIndex
            guard bytesRead == Int(lengthOfCustomData) else {
                throw DecoderError.rdataLengthMismatch(expected: Int(lengthOfCustomData), actual: bytesRead)
            }
            return NSRecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                lengthOfCustomData: lengthOfCustomData,
                paylodLabels: payloadLabels
            )
        case .cname:
            // Decode the canonical name from the RDATA.
            // Use the full packet buffer to support compression pointers.
            var cnameBuffer: any ByteBufferReading = ByteBufferReader(byteBuffer.data)
            cnameBuffer.currentIndex = rdataStartIndex
            let payloadLabels = try DNSLabels.decode(from: &cnameBuffer)
            let bytesRead = cnameBuffer.currentIndex - rdataStartIndex
            guard bytesRead == Int(lengthOfCustomData) else {
                throw DecoderError.rdataLengthMismatch(expected: Int(lengthOfCustomData), actual: bytesRead)
            }
            return CNAMERecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                lengthOfCustomData: lengthOfCustomData,
                paylodLabels: payloadLabels
            )
        case .mx:
            // Decode priority and mail server domain from the RDATA.
            // Use the full packet buffer to support compression pointers.
            var mxBuffer: any ByteBufferReading = ByteBufferReader(byteBuffer.data)
            mxBuffer.currentIndex = rdataStartIndex
            let priority = try mxBuffer.readUInt16()
            let payloadLabels = try DNSLabels.decode(from: &mxBuffer)
            let bytesRead = mxBuffer.currentIndex - rdataStartIndex
            guard bytesRead == Int(lengthOfCustomData) else {
                throw DecoderError.rdataLengthMismatch(expected: Int(lengthOfCustomData), actual: bytesRead)
            }
            return MXRecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                lengthOfCustomData: lengthOfCustomData,
                priority: priority,
                paylodLabels: payloadLabels
            )
        case .soa:
            // Decode SOA record fields from the RDATA.
            // Use the full packet buffer to support compression pointers.
            var soaBuffer: any ByteBufferReading = ByteBufferReader(byteBuffer.data)
            soaBuffer.currentIndex = rdataStartIndex
            let primaryNameServer = try DNSLabels.decode(from: &soaBuffer)
            let responsibleMailbox = try DNSLabels.decode(from: &soaBuffer)
            let serial = try soaBuffer.readUInt32()
            let refresh = try soaBuffer.readUInt32()
            let retry = try soaBuffer.readUInt32()
            let expire = try soaBuffer.readUInt32()
            let minimum = try soaBuffer.readUInt32()
            let bytesRead = soaBuffer.currentIndex - rdataStartIndex
            guard bytesRead == Int(lengthOfCustomData) else {
                throw DecoderError.rdataLengthMismatch(expected: Int(lengthOfCustomData), actual: bytesRead)
            }
            return SOARecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                lengthOfCustomData: lengthOfCustomData,
                primaryNameServer: primaryNameServer,
                responsibleMailbox: responsibleMailbox,
                serial: serial,
                refresh: refresh,
                retry: retry,
                expire: expire,
                minimum: minimum
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
