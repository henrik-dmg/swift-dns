//
//  SRVRecord.swift
//  swift-dns
//
//  Created by Henrik Panhans on 15.05.26.
//

/// Represents an SRV (Service Locator) record, which specifies the location of services for a domain.
///
/// SRV records are used for service discovery, providing the hostname and port number for specific services.
public struct SRVRecord: DNSRecord, DNSRecordEncodable {

    public let labels: DNSLabels
    public let recordType: DNSRecordType
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

    func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        buffer.write(priority)
        buffer.write(weight)
        buffer.write(port)
        try buffer.write(target)
    }

}
