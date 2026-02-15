//
//  PTRRecord.swift
//  swift-dns
//
//  Created by Henrik Panhans on 15.05.26.
//

/// Represents a PTR (Pointer) record, which maps an IP address to a domain name.
///
/// PTR records are primarily used for reverse DNS lookups, where an IP address is resolved to its associated domain name.
public struct PTRRecord: DNSRecord, DNSRecordEncodable {

    public let labels: DNSLabels
    public let recordType: DNSRecordType
    public let recordClass: UInt16
    public let timeToLive: UInt32

    /// The domain name that the pointer refers to.
    public let domainName: DNSLabels

    public var lengthOfCustomData: UInt16 {
        UInt16(domainName.uncompressedByteLength)
    }

    func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        try buffer.write(domainName)
    }

}
