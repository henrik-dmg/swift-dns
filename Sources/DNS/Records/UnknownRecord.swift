//
//  UnknownRecord.swift
//  swift-dns
//
//  Created by Henrik Panhans on 15.05.26.
//

import Foundation

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
