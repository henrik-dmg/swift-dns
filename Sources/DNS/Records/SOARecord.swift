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
public struct SOARecord: DNSRecord, DNSRecordEncodable {

    public let labels: DNSLabels
    public let recordType: DNSRecordType
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
