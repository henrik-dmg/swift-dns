//
//  ARecord.swift
//  swift-dns
//
//  Created by Henrik Panhans on 15.05.26.
//

/// Represents an A (Address) record, which maps a domain name to an IPv4 address.
///
/// A records are used to resolve hostnames to their corresponding IPv4 addresses.
///
/// ```swift
/// let record = ARecord(
///     labels: ["example", "com"],
///     timeToLive: 300,
///     address: IPv4Address(93, 184, 216, 34)
/// )
/// ```
public struct ARecord: DNSRecord, CustomDebugStringConvertible, DNSRecordEncodable {

    public let labels: DNSLabels
    public let recordType: DNSRecordType = .a
    public let recordClass: UInt16
    public let timeToLive: UInt32

    /// The IPv4 address associated with the domain name.
    public let address: IPv4Address

    public var lengthOfCustomData: UInt16 {
        4  // IPv4 addresses have 4 octets
    }

    public var debugDescription: String {
        "A(\(labels.labels), class \(recordClass), TTL \(timeToLive), IP: \(address))"
    }

    // MARK: - Encoding

    func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        try address.encode(into: &buffer)
    }

}

// MARK: - Init

extension ARecord {

    /// Creates a new A record.
    ///
    /// - Parameters:
    ///   - labels: The domain name labels (e.g., `["example", "com"]`).
    ///   - recordClass: The record class. Defaults to `1` (Internet).
    ///   - timeToLive: The time in seconds that this record may be cached.
    ///   - address: The IPv4 address for the domain.
    public init(labels: [String], recordClass: UInt16 = 1, timeToLive: UInt32, address: IPv4Address) {
        self.labels = DNSLabels(labels: labels)
        self.recordClass = recordClass
        self.timeToLive = timeToLive
        self.address = address
    }

}
