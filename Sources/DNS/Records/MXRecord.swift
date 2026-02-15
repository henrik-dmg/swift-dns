//
//  MXRecord.swift
//  swift-dns
//
//  Created by Henrik Panhans on 15.05.26.
//

/// Represents an MX (Mail Exchange) record, which specifies the mail server responsible for accepting email messages on behalf of a domain.
///
/// MX records include a priority value to allow for multiple mail servers with different priorities.
///
/// ```swift
/// let record = MXRecord(
///     labels: ["example", "com"],
///     timeToLive: 3600,
///     priority: 10,
///     payloadLabels: ["mail", "example", "com"]
/// )
/// ```
public struct MXRecord: DNSRecord, DNSRecordEncodable {

    public let labels: DNSLabels
    public let recordType: DNSRecordType = .mx
    public let recordClass: UInt16
    public let timeToLive: UInt32

    /// The priority of the mail server.
    ///
    /// Lower values indicate higher priority.
    public let priority: UInt16

    /// The domain name of the mail server.
    public let payloadLabels: DNSLabels

    public var lengthOfCustomData: UInt16 {
        UInt16(2 + payloadLabels.uncompressedByteLength)  // 2 bytes for priority
    }

    // MARK: - Encoding

    func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        buffer.write(priority)
        try buffer.write(payloadLabels)
    }

}

// MARK: - Init

extension MXRecord {

    /// Creates a new MX record.
    ///
    /// - Parameters:
    ///   - labels: The domain name labels (e.g., `["example", "com"]`).
    ///   - recordClass: The record class. Defaults to `1` (Internet).
    ///   - timeToLive: The time in seconds that this record may be cached.
    ///   - priority: The mail server priority (lower values are preferred).
    ///   - payloadLabels: The mail server's domain name labels (e.g., `["mail", "example", "com"]`).
    public init(
        labels: [String],
        recordClass: UInt16 = 1,
        timeToLive: UInt32,
        priority: UInt16,
        payloadLabels: [String]
    ) {
        self.labels = DNSLabels(labels: labels)
        self.recordClass = recordClass
        self.timeToLive = timeToLive
        self.priority = priority
        self.payloadLabels = DNSLabels(labels: payloadLabels)
    }

}
