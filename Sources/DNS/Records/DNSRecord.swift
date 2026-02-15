//
//  DNSRecord.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

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
    /// This includes the common fields and the record-specific data. The RDATA length field is
    /// computed dynamically to account for label compression potentially changing the encoded size.
    func encode(into buffer: inout ByteBufferWriting) throws {
        try buffer.write(labels)
        try recordType.encode(into: &buffer)
        buffer.write(recordClass)
        buffer.write(timeToLive)

        if let encodable = self as? DNSRecordEncodable {
            let lengthIndex = buffer.currentIndex
            buffer.write(UInt16(0))
            let rdataStart = buffer.currentIndex
            try encodable.encodeAdditionalData(into: &buffer)
            let rdataLength = buffer.currentIndex - rdataStart
            buffer.write(UInt16(rdataLength), at: lengthIndex)
        } else {
            buffer.write(lengthOfCustomData)
        }
    }

}
