//
//  AAAARecord.swift
//  swift-dns
//
//  Created by Henrik Panhans on 15.05.26.
//

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
