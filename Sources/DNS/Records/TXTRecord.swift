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
///
/// ```swift
/// let record = TXTRecord(
///     labels: ["example", "com"],
///     timeToLive: 3600,
///     content: "v=spf1 include:_spf.example.com ~all"
/// )
/// ```
public struct TXTRecord: DNSRecord, DNSRecordEncodable {

    public let labels: DNSLabels
    public let recordType: DNSRecordType = .txt
    public let recordClass: UInt16
    public let timeToLive: UInt32

    /// The text content of the record.
    public let content: String

    public var lengthOfCustomData: UInt16 {
        UInt16(content.count) + 1  // + 1 because one byte is added to define the length of the following string
    }

    // MARK: - Encoding

    func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        buffer.write(UInt8(content.count))
        guard let contentData = content.data(using: .ascii) else {
            throw EncoderError.cantConvertStringToData(content)
        }
        buffer.write(contentData)
    }

}

// MARK: - Init

extension TXTRecord {

    /// Creates a new TXT record.
    ///
    /// - Parameters:
    ///   - labels: The domain name labels (e.g., `["example", "com"]`).
    ///   - recordClass: The record class. Defaults to `1` (Internet).
    ///   - timeToLive: The time in seconds that this record may be cached.
    ///   - content: The text content of the record.
    public init(labels: [String], recordClass: UInt16 = 1, timeToLive: UInt32, content: String) {
        self.labels = DNSLabels(labels: labels)
        self.recordClass = recordClass
        self.timeToLive = timeToLive
        self.content = content
    }

}
