//
//  AAAARecord.swift
//  swift-dns
//
//  Created by Henrik Panhans on 15.05.26.
//

/// Represents an AAAA (IPv6 Address) record, which maps a domain name to an IPv6 address.
///
/// AAAA records are used to resolve hostnames to their corresponding IPv6 addresses.
///
/// ```swift
/// let record = AAAARecord(
///     labels: ["example", "com"],
///     timeToLive: 300,
///     address: IPv6Address(0x2606, 0x2800, 0x0220, 0x0001, 0x0248, 0x1893, 0x25c8, 0x1946)
/// )
/// ```
public struct AAAARecord: DNSRecord, CustomDebugStringConvertible, DNSRecordEncodable {

    public let labels: DNSLabels
    public let recordType: DNSRecordType = .aaaa
    public let recordClass: UInt16
    public let timeToLive: UInt32

    /// The IPv6 address associated with the domain name.
    public let address: IPv6Address

    public var lengthOfCustomData: UInt16 {
        16  // IPv6 addresses have 16 octets
    }

    public var debugDescription: String {
        "AAAA(\(labels.labels), class \(recordClass), TTL \(timeToLive), IP: \(address))"
    }

    // MARK: - Encoding

    func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        try address.encode(into: &buffer)
    }

}

// MARK: - Init

extension AAAARecord {

    /// Creates a new AAAA record.
    ///
    /// - Parameters:
    ///   - labels: The domain name labels (e.g., `["example", "com"]`).
    ///   - recordClass: The record class. Defaults to `1` (Internet).
    ///   - timeToLive: The time in seconds that this record may be cached.
    ///   - address: The IPv6 address for the domain.
    public init(labels: [String], recordClass: UInt16 = 1, timeToLive: UInt32, address: IPv6Address) {
        self.labels = DNSLabels(labels: labels)
        self.recordClass = recordClass
        self.timeToLive = timeToLive
        self.address = address
    }

}
