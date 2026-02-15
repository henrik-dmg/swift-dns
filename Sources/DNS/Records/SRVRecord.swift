//
//  SRVRecord.swift
//  swift-dns
//
//  Created by Henrik Panhans on 15.05.26.
//

/// Represents an SRV (Service Locator) record, which specifies the location of services for a domain.
///
/// SRV records are used for service discovery, providing the hostname and port number for specific services.
///
/// ```swift
/// let record = SRVRecord(
///     labels: ["_sip", "_tcp", "example", "com"],
///     timeToLive: 3600,
///     priority: 10,
///     weight: 60,
///     port: 5060,
///     target: ["sip", "example", "com"]
/// )
/// ```
public struct SRVRecord: DNSRecord, DNSRecordEncodable {

    public let labels: DNSLabels
    public let recordType: DNSRecordType = .srv
    public let recordClass: UInt16
    public let timeToLive: UInt32

    /// The priority of this target host (lower = preferred).
    public let priority: UInt16

    /// The weight for records with the same priority (higher = more likely to be selected).
    public let weight: UInt16

    /// The TCP or UDP port on which the service is to be found.
    public let port: UInt16

    /// The domain name of the target host.
    public let target: DNSLabels

    public var lengthOfCustomData: UInt16 {
        UInt16(6 + target.uncompressedByteLength)  // 3 x UInt16 + target
    }

    // MARK: - Encoding

    func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        buffer.write(priority)
        buffer.write(weight)
        buffer.write(port)
        try buffer.write(target)
    }

}

// MARK: - Init

extension SRVRecord {

    /// Creates a new SRV record.
    ///
    /// - Parameters:
    ///   - labels: The service domain name labels (e.g., `["_sip", "_tcp", "example", "com"]`).
    ///   - recordClass: The record class. Defaults to `1` (Internet).
    ///   - timeToLive: The time in seconds that this record may be cached.
    ///   - priority: The target host priority (lower values are preferred).
    ///   - weight: The weight for load balancing among hosts with equal priority.
    ///   - port: The port number for the service.
    ///   - target: The target host's domain name labels (e.g., `["sip", "example", "com"]`).
    public init(
        labels: [String],
        recordClass: UInt16 = 1,
        timeToLive: UInt32,
        priority: UInt16,
        weight: UInt16,
        port: UInt16,
        target: [String]
    ) {
        self.labels = DNSLabels(labels: labels)
        self.recordClass = recordClass
        self.timeToLive = timeToLive
        self.priority = priority
        self.weight = weight
        self.port = port
        self.target = DNSLabels(labels: target)
    }

}
