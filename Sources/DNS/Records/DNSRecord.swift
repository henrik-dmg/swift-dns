//
//  DNSRecord.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

// MARK: - Base Protocol

/// The base protocol for all DNS resource records.
///
/// DNS records are the fundamental data units in the DNS system, containing information about domain names.
/// Each record type has specific fields and data formats as defined in various RFCs.
public protocol DNSRecord: Equatable, Sendable {

    /// The domain name to which this record applies, represented as DNS labels.
    var labels: DNSLabels { get }

    /// The type of DNS record (e.g., A, AAAA, NS, MX, etc.).
    var recordType: DNSRecordType { get }

    /// The class of the record. For Internet DNS, this is typically IN (Internet) = 1.
    var recordClass: UInt16 { get }

    /// The time in seconds that the record may be cached before it should be discarded.
    var timeToLive: UInt32 { get }

    /// The length of the record-specific data in bytes.
    var lengthOfCustomData: UInt16 { get }

}

protocol DNSRecordEncodable {

    func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws(EncoderError)

}

extension DNSRecord {

    /// Encodes the complete DNS record into the provided buffer.
    ///
    /// This includes both the common fields and the record-specific data.
    func encode(into buffer: inout ByteBufferWriting) throws {
        try encodeSharedValues(into: &buffer)
        if let encodable = self as? DNSRecordEncodable {
            try encodable.encodeAdditionalData(into: &buffer)
        }
    }

    /// Encodes the common fields shared by all DNS records.
    ///
    /// This includes the domain name, record type, class, TTL, and data length.
    func encodeSharedValues(into buffer: inout ByteBufferWriting) throws {
        try buffer.write(labels)
        try recordType.encode(into: &buffer)
        buffer.write(recordClass)
        buffer.write(timeToLive)
        buffer.write(lengthOfCustomData)
    }

}

// MARK: - Unknown Record Type

/// Represents a DNS record of an unknown or unsupported type.
///
/// This record type is used when the DNS server returns a record type that is not explicitly supported by this implementation.
public struct UnknownRecord: DNSRecord, DNSRecordEncodable {

    public let labels: DNSLabels
    public let recordType: DNSRecordType
    public let recordClass: UInt16
    public let timeToLive: UInt32
    public let lengthOfCustomData: UInt16

    /// The raw bytes of the record data.
    public let bytes: Data

    func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        buffer.write(bytes)
    }

}

// MARK: - A Record

/// Represents an A (Address) record, which maps a domain name to an IPv4 address.
///
/// A records are used to resolve hostnames to their corresponding IPv4 addresses.
public struct ARecord: DNSRecord, CustomDebugStringConvertible, DNSRecordEncodable {

    public let labels: DNSLabels
    public let recordType: DNSRecordType
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

    func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        try address.encode(into: &buffer)
    }

}

// MARK: - AAAA Record

/// Represents an AAAA (IPv6 Address) record, which maps a domain name to an IPv6 address.
///
/// AAAA records are used to resolve hostnames to their corresponding IPv6 addresses.
public struct AAAARecord: DNSRecord, CustomDebugStringConvertible, DNSRecordEncodable {

    public let labels: DNSLabels
    public let recordType: DNSRecordType
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

    func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        try address.encode(into: &buffer)
    }

}

// MARK: - NS Record

/// Represents an NS (Name Server) record, which specifies the authoritative name servers for a domain.
///
/// NS records are used to delegate a subdomain to a set of name servers.
public struct NSRecord: DNSRecord, DNSRecordEncodable {

    public let labels: DNSLabels
    public let recordType: DNSRecordType
    public let recordClass: UInt16
    public let timeToLive: UInt32
    public let lengthOfCustomData: UInt16

    /// The domain name of the name server.
    public let payloadLabels: DNSLabels

    func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        try buffer.write(payloadLabels)
    }

}

// MARK: - CNAME Record

/// Represents a CNAME (Canonical Name) record, which maps an alias name to the true or canonical name.
///
/// CNAME records are used to create aliases for domain names.
public struct CNAMERecord: DNSRecord, DNSRecordEncodable {

    public let labels: DNSLabels
    public let recordType: DNSRecordType
    public let recordClass: UInt16
    public let timeToLive: UInt32
    public let lengthOfCustomData: UInt16

    /// The canonical domain name that the alias points to.
    public let payloadLabels: DNSLabels

    func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        try buffer.write(payloadLabels)
    }

}

// MARK: - MX Record

/// Represents an MX (Mail Exchange) record, which specifies the mail server responsible for accepting email messages on behalf of a domain.
///
/// MX records include a priority value to allow for multiple mail servers with different priorities.
public struct MXRecord: DNSRecord, DNSRecordEncodable {

    public let labels: DNSLabels
    public let recordType: DNSRecordType
    public let recordClass: UInt16
    public let timeToLive: UInt32
    public let lengthOfCustomData: UInt16

    /// The priority of the mail server.
    ///
    /// Lower values indicate higher priority.
    public let priority: UInt16

    /// The domain name of the mail server.
    public let payloadLabels: DNSLabels

    func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        buffer.write(priority)
        try buffer.write(payloadLabels)
    }

}

// MARK: - SOA Record

/// Represents an SOA (Start of Authority) record, which specifies authoritative information about a DNS zone.
///
/// SOA records contain administrative information about the zone including the primary name server,
/// the email of the domain administrator, and various timers for zone transfers.
public struct SOARecord: DNSRecord, DNSRecordEncodable {

    public let labels: DNSLabels
    public let recordType: DNSRecordType
    public let recordClass: UInt16
    public let timeToLive: UInt32
    public let lengthOfCustomData: UInt16

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

// MARK: - TXT Record

/// Represents a TXT (Text) record, which can contain arbitrary text data.
///
/// TXT records are commonly used for various purposes including SPF records, DKIM records, and general information.
public struct TXTRecord: DNSRecord, DNSRecordEncodable {

    public let labels: DNSLabels
    public let recordType: DNSRecordType
    public let recordClass: UInt16
    public let timeToLive: UInt32

    /// The text content of the record.
    public let content: String

    public var lengthOfCustomData: UInt16 {
        UInt16(content.count) + 1  // + 1 because one byte is added to define the length of the following string
    }

    func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        buffer.write(UInt8(content.count))
        guard let contentData = content.data(using: .ascii) else {
            throw EncoderError.cantConvertStringToData(content)
        }
        buffer.write(contentData)
    }

}
