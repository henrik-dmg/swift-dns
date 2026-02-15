//
//  PTRRecord.swift
//  swift-dns
//
//  Created by Henrik Panhans on 15.05.26.
//

/// Represents a PTR (Pointer) record, which maps an IP address to a domain name.
///
/// PTR records are primarily used for reverse DNS lookups, where an IP address is resolved to its associated domain name.
///
/// ```swift
/// let record = PTRRecord(
///     labels: ["34", "216", "184", "93", "in-addr", "arpa"],
///     timeToLive: 3600,
///     domainName: ["example", "com"]
/// )
/// ```
public struct PTRRecord: DNSRecord, DNSRecordEncodable {

    public let labels: DNSLabels
    public let recordType: DNSRecordType = .ptr
    public let recordClass: UInt16
    public let timeToLive: UInt32

    /// The domain name that the pointer refers to.
    public let domainName: DNSLabels

    public var lengthOfCustomData: UInt16 {
        UInt16(domainName.uncompressedByteLength)
    }

    // MARK: - Encoding

    func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        try buffer.write(domainName)
    }

}

// MARK: - Init

extension PTRRecord {

    /// Creates a new PTR record.
    ///
    /// - Parameters:
    ///   - labels: The reverse lookup domain name labels
    ///     (e.g., `["34", "216", "184", "93", "in-addr", "arpa"]` for `93.184.216.34`).
    ///   - recordClass: The record class. Defaults to `1` (Internet).
    ///   - timeToLive: The time in seconds that this record may be cached.
    ///   - domainName: The target domain name labels (e.g., `["example", "com"]`).
    public init(labels: [String], recordClass: UInt16 = 1, timeToLive: UInt32, domainName: [String]) {
        self.labels = DNSLabels(labels: labels)
        self.recordClass = recordClass
        self.timeToLive = timeToLive
        self.domainName = DNSLabels(labels: domainName)
    }

}
