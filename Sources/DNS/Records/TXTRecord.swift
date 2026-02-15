//
//  TXTRecord.swift
//  swift-dns
//
//  Created by Henrik Panhans on 15.05.26.
//

import Foundation

/// Represents a TXT (Text) record, which can contain arbitrary text data.
///
/// TXT records are commonly used for various purposes including SPF records, DKIM records, and general information.
public struct TXTRecord: DNSRecord, DNSRecordEncodable {

    public let labels: DNSLabels
    public let recordType: DNSRecordType
    public let recordClass: UInt16
    public let timeToLive: UInt32

    /// The text content of the record.
    public let content: String

    public var lengthOfCustomData: UInt16 {
        UInt16(content.count) + 1  // + 1 because one byte is added to define the length of the following string
    }

    func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        buffer.write(UInt8(content.count))
        guard let contentData = content.data(using: .ascii) else {
            throw EncoderError.cantConvertStringToData(content)
        }
        buffer.write(contentData)
    }

}
