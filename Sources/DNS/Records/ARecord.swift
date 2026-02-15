//
//  ARecord.swift
//  swift-dns
//
//  Created by Henrik Panhans on 15.05.26.
//

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
