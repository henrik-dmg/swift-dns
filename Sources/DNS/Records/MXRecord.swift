//
//  MXRecord.swift
//  swift-dns
//
//  Created by Henrik Panhans on 15.05.26.
//

/// Represents an MX (Mail Exchange) record, which specifies the mail server responsible for accepting email messages on behalf of a domain.
///
/// MX records include a priority value to allow for multiple mail servers with different priorities.
public struct MXRecord: DNSRecord, DNSRecordEncodable {

    public let labels: DNSLabels
    public let recordType: DNSRecordType
    public let recordClass: UInt16
    public let timeToLive: UInt32

    /// The priority of the mail server.
    ///
    /// Lower values indicate higher priority.
    public let priority: UInt16

    /// The domain name of the mail server.
    public let payloadLabels: DNSLabels

    public var lengthOfCustomData: UInt16 {
        UInt16(2 + payloadLabels.uncompressedByteLength)  // 2 bytes for priority
    }

    func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        buffer.write(priority)
        try buffer.write(payloadLabels)
    }

}
