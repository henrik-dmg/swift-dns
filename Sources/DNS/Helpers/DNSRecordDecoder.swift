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
        let lengthOfCustomData = Int(try byteBuffer.readUInt16())

        // Save the position where RDATA starts for records that need full packet access
        let rdataStartIndex = byteBuffer.currentIndex

        switch recordType {
        case .a:
            // Decodes an IPv4 A record
            guard lengthOfCustomData == 4 else {
                throw DecoderError.rdataLengthMismatch(expected: 4, actual: lengthOfCustomData)
            }
            let fragments = try byteBuffer.readBytes(lengthOfCustomData)
            return ARecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                address: IPv4Address(fragments: Array(fragments))
            )
        case .aaaa:
            // Decodes an IPv6 AAAA record
            guard lengthOfCustomData == 16 else {
                throw DecoderError.rdataLengthMismatch(expected: 16, actual: lengthOfCustomData)
            }
            let fragments = try byteBuffer.readBytes(lengthOfCustomData)
            return AAAARecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                address: try IPv6Address(fragments: Array(fragments))
            )
        case .ns:
            // Decode the nameserver domain from the RDATA.
            // Use the full packet buffer to support compression pointers.
            var nsBuffer: any ByteBufferReading = ByteBufferReader(byteBuffer.data)
            nsBuffer.currentIndex = rdataStartIndex
            let payloadLabels = try DNSLabels.decode(from: &nsBuffer)
            let bytesRead = nsBuffer.currentIndex - rdataStartIndex
            guard bytesRead == lengthOfCustomData else {
                throw DecoderError.rdataLengthMismatch(expected: lengthOfCustomData, actual: bytesRead)
            }
            // Advance the original buffer past the RDATA section
            byteBuffer.currentIndex = rdataStartIndex + lengthOfCustomData
            return NSRecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                payloadLabels: payloadLabels
            )
        case .cname:
            // Decode the canonical name from the RDATA.
            // Use the full packet buffer to support compression pointers.
            var cnameBuffer: any ByteBufferReading = ByteBufferReader(byteBuffer.data)
            cnameBuffer.currentIndex = rdataStartIndex
            let payloadLabels = try DNSLabels.decode(from: &cnameBuffer)
            let bytesRead = cnameBuffer.currentIndex - rdataStartIndex
            guard bytesRead == lengthOfCustomData else {
                throw DecoderError.rdataLengthMismatch(expected: lengthOfCustomData, actual: bytesRead)
            }
            // Advance the original buffer past the RDATA section
            byteBuffer.currentIndex = rdataStartIndex + lengthOfCustomData
            return CNAMERecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                payloadLabels: payloadLabels
            )
        case .mx:
            // Decode priority and mail server domain from the RDATA.
            // Use the full packet buffer to support compression pointers.
            var mxBuffer: any ByteBufferReading = ByteBufferReader(byteBuffer.data)
            mxBuffer.currentIndex = rdataStartIndex
            let priority = try mxBuffer.readUInt16()
            let payloadLabels = try DNSLabels.decode(from: &mxBuffer)
            let bytesRead = mxBuffer.currentIndex - rdataStartIndex
            guard bytesRead == lengthOfCustomData else {
                throw DecoderError.rdataLengthMismatch(expected: lengthOfCustomData, actual: bytesRead)
            }
            // Advance the original buffer past the RDATA section
            byteBuffer.currentIndex = rdataStartIndex + lengthOfCustomData
            return MXRecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                priority: priority,
                payloadLabels: payloadLabels
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
            guard bytesRead == lengthOfCustomData else {
                throw DecoderError.rdataLengthMismatch(expected: lengthOfCustomData, actual: bytesRead)
            }
            // Advance the original buffer past the RDATA section
            byteBuffer.currentIndex = rdataStartIndex + lengthOfCustomData
            return SOARecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
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
            let customData = try byteBuffer.readBytes(lengthOfCustomData)
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
        case .ptr:
            // Decode the pointer domain from the RDATA.
            // Use the full packet buffer to support compression pointers.
            var ptrBuffer: any ByteBufferReading = ByteBufferReader(byteBuffer.data)
            ptrBuffer.currentIndex = rdataStartIndex
            let domainName = try DNSLabels.decode(from: &ptrBuffer)
            let bytesRead = ptrBuffer.currentIndex - rdataStartIndex
            guard bytesRead == lengthOfCustomData else {
                throw DecoderError.rdataLengthMismatch(expected: lengthOfCustomData, actual: bytesRead)
            }
            // Advance the original buffer past the RDATA section
            byteBuffer.currentIndex = rdataStartIndex + lengthOfCustomData
            return PTRRecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                domainName: domainName
            )
        case .srv:
            // Decode SRV record fields from the RDATA.
            // Use the full packet buffer to support compression pointers.
            var srvBuffer: any ByteBufferReading = ByteBufferReader(byteBuffer.data)
            srvBuffer.currentIndex = rdataStartIndex
            let priority = try srvBuffer.readUInt16()
            let weight = try srvBuffer.readUInt16()
            let port = try srvBuffer.readUInt16()
            let target = try DNSLabels.decode(from: &srvBuffer)
            let bytesRead = srvBuffer.currentIndex - rdataStartIndex
            guard bytesRead == lengthOfCustomData else {
                throw DecoderError.rdataLengthMismatch(expected: lengthOfCustomData, actual: bytesRead)
            }
            // Advance the original buffer past the RDATA section
            byteBuffer.currentIndex = rdataStartIndex + lengthOfCustomData
            return SRVRecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                priority: priority,
                weight: weight,
                port: port,
                target: target
            )
        case .unknown:
            let customData = try byteBuffer.readBytes(lengthOfCustomData)
            return UnknownRecord(
                labels: labels,
                recordType: recordType,
                recordClass: recordClass,
                timeToLive: timeToLive,
                lengthOfCustomData: UInt16(lengthOfCustomData),
                bytes: customData
            )
        }
    }

}
