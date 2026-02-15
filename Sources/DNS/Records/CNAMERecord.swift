//
//  CNAMERecord.swift
//  swift-dns
//
//  Created by Henrik Panhans on 15.05.26.
//

/// Represents a CNAME (Canonical Name) record, which maps an alias name to the true or canonical name.
///
/// CNAME records are used to create aliases for domain names.
public struct CNAMERecord: DNSRecord, DNSRecordEncodable {

    public let labels: DNSLabels
    public let recordType: DNSRecordType
    public let recordClass: UInt16
    public let timeToLive: UInt32

    /// The canonical domain name that the alias points to.
    public let payloadLabels: DNSLabels

    public var lengthOfCustomData: UInt16 {
        UInt16(payloadLabels.uncompressedByteLength)
    }

    func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        try buffer.write(payloadLabels)
    }

}
