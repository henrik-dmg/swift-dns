//
//  SOARecord.swift
//  swift-dns
//
//  Created by Henrik Panhans on 15.05.26.
//

/// Represents an SOA (Start of Authority) record, which specifies authoritative information about a DNS zone.
///
/// SOA records contain administrative information about the zone including the primary name server,
/// the email of the domain administrator, and various timers for zone transfers.
///
/// ```swift
/// let record = SOARecord(
///     labels: ["example", "com"],
///     timeToLive: 3600,
///     primaryNameServer: ["ns1", "example", "com"],
///     responsibleMailbox: ["admin", "example", "com"],
///     serial: 2024010101,
///     refresh: 7200,
///     retry: 3600,
///     expire: 1209600,
///     minimum: 86400
/// )
/// ```
public struct SOARecord: DNSRecord, DNSRecordEncodable {

    public let labels: DNSLabels
    public let recordType: DNSRecordType = .soa
    public let recordClass: UInt16
    public let timeToLive: UInt32

    /// The domain name of the primary name server for this zone.
    public let primaryNameServer: DNSLabels

    /// The domain name which specifies the mailbox of the person responsible for this zone.
    ///
    /// The format is typically: `username.domain.com` where the first dot represents the @ symbol in the email address.
    public let responsibleMailbox: DNSLabels

    /// The version number of the original copy of the zone.
    ///
    /// Zone transfers preserve this value. This value wraps and should be compared using sequence space arithmetic.
    public let serial: UInt32

    /// The time interval (in seconds) before the zone should be refreshed.
    public let refresh: UInt32

    /// The time interval (in seconds) that should elapse before a failed refresh should be retried.
    public let retry: UInt32

    /// The time value (in seconds) that specifies the upper limit on the time interval that can elapse before
    /// the zone is no longer authoritative.
    public let expire: UInt32

    /// The minimum TTL field that should be exported with any RR from this zone.
    public let minimum: UInt32

    public var lengthOfCustomData: UInt16 {
        // MNAME + RNAME (uncompressed) + 5 x UInt32 (20 bytes)
        UInt16(primaryNameServer.uncompressedByteLength + responsibleMailbox.uncompressedByteLength + 20)
    }

    // MARK: - Encoding

    func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        try buffer.write(primaryNameServer)
        try buffer.write(responsibleMailbox)
        buffer.write(serial)
        buffer.write(refresh)
        buffer.write(retry)
        buffer.write(expire)
        buffer.write(minimum)
    }

}

// MARK: - Init

extension SOARecord {

    /// Creates a new SOA record.
    ///
    /// - Parameters:
    ///   - labels: The domain name labels (e.g., `["example", "com"]`).
    ///   - recordClass: The record class. Defaults to `1` (Internet).
    ///   - timeToLive: The time in seconds that this record may be cached.
    ///   - primaryNameServer: The primary name server's domain name labels.
    ///   - responsibleMailbox: The responsible person's mailbox as domain name labels
    ///     (e.g., `["admin", "example", "com"]` for `admin@example.com`).
    ///   - serial: The zone's serial number.
    ///   - refresh: The refresh interval in seconds.
    ///   - retry: The retry interval in seconds.
    ///   - expire: The expire interval in seconds.
    ///   - minimum: The minimum TTL in seconds.
    public init(
        labels: [String],
        recordClass: UInt16 = 1,
        timeToLive: UInt32,
        primaryNameServer: [String],
        responsibleMailbox: [String],
        serial: UInt32,
        refresh: UInt32,
        retry: UInt32,
        expire: UInt32,
        minimum: UInt32
    ) {
        self.labels = DNSLabels(labels: labels)
        self.recordClass = recordClass
        self.timeToLive = timeToLive
        self.primaryNameServer = DNSLabels(labels: primaryNameServer)
        self.responsibleMailbox = DNSLabels(labels: responsibleMailbox)
        self.serial = serial
        self.refresh = refresh
        self.retry = retry
        self.expire = expire
        self.minimum = minimum
    }

}
