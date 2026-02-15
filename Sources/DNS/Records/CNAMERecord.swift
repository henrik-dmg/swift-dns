//
//  CNAMERecord.swift
//  swift-dns
//
//  Created by Henrik Panhans on 15.05.26.
//

/// Represents a CNAME (Canonical Name) record, which maps an alias name to the true or canonical name.
///
/// CNAME records are used to create aliases for domain names.
///
/// ```swift
/// let record = CNAMERecord(
///     labels: ["www", "example", "com"],
///     timeToLive: 3600,
///     payloadLabels: ["example", "com"]
/// )
/// ```
public struct CNAMERecord: DNSRecord, DNSRecordEncodable {

    public let labels: DNSLabels
    public let recordType: DNSRecordType = .cname
    public let recordClass: UInt16
    public let timeToLive: UInt32

    /// The canonical domain name that the alias points to.
    public let payloadLabels: DNSLabels

    public var lengthOfCustomData: UInt16 {
        UInt16(payloadLabels.uncompressedByteLength)
    }

    // MARK: - Encoding

    func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        try buffer.write(payloadLabels)
    }

}

// MARK: - Init

extension CNAMERecord {

    /// Creates a new CNAME record.
    ///
    /// - Parameters:
    ///   - labels: The alias domain name labels (e.g., `["www", "example", "com"]`).
    ///   - recordClass: The record class. Defaults to `1` (Internet).
    ///   - timeToLive: The time in seconds that this record may be cached.
    ///   - payloadLabels: The canonical domain name labels (e.g., `["example", "com"]`).
    public init(labels: [String], recordClass: UInt16 = 1, timeToLive: UInt32, payloadLabels: [String]) {
        self.labels = DNSLabels(labels: labels)
        self.recordClass = recordClass
        self.timeToLive = timeToLive
        self.payloadLabels = DNSLabels(labels: payloadLabels)
    }

}
