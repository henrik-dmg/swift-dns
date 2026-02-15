//
//  NSRecord.swift
//  swift-dns
//
//  Created by Henrik Panhans on 15.05.26.
//

/// Represents an NS (Name Server) record, which specifies the authoritative name servers for a domain.
///
/// NS records are used to delegate a subdomain to a set of name servers.
///
/// ```swift
/// let record = NSRecord(
///     labels: ["example", "com"],
///     timeToLive: 86400,
///     payloadLabels: ["ns1", "example", "com"]
/// )
/// ```
public struct NSRecord: DNSRecord, DNSRecordEncodable {

    public let labels: DNSLabels
    public let recordType: DNSRecordType = .ns
    public let recordClass: UInt16
    public let timeToLive: UInt32

    /// The domain name of the name server.
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

extension NSRecord {

    /// Creates a new NS record.
    ///
    /// - Parameters:
    ///   - labels: The domain name labels (e.g., `["example", "com"]`).
    ///   - recordClass: The record class. Defaults to `1` (Internet).
    ///   - timeToLive: The time in seconds that this record may be cached.
    ///   - payloadLabels: The name server's domain name labels (e.g., `["ns1", "example", "com"]`).
    public init(labels: [String], recordClass: UInt16 = 1, timeToLive: UInt32, payloadLabels: [String]) {
        self.labels = DNSLabels(labels: labels)
        self.recordClass = recordClass
        self.timeToLive = timeToLive
        self.payloadLabels = DNSLabels(labels: payloadLabels)
    }

}
