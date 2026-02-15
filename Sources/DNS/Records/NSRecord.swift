//
//  NSRecord.swift
//  swift-dns
//
//  Created by Henrik Panhans on 15.05.26.
//

/// Represents an NS (Name Server) record, which specifies the authoritative name servers for a domain.
///
/// NS records are used to delegate a subdomain to a set of name servers.
public struct NSRecord: DNSRecord, DNSRecordEncodable {

    public let labels: DNSLabels
    public let recordType: DNSRecordType
    public let recordClass: UInt16
    public let timeToLive: UInt32

    /// The domain name of the name server.
    public let payloadLabels: DNSLabels

    public var lengthOfCustomData: UInt16 {
        UInt16(payloadLabels.uncompressedByteLength)
    }

    func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        try buffer.write(payloadLabels)
    }

}
