//
//  DNSRecord.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

// MARK: - Base Protocol

public protocol DNSRecord: Sendable {
    var labels: DNSLabels { get }
    var recordType: DNSRecordType { get }
    var recordClass: UInt16 { get }
    var timeToLive: UInt32 { get }
}

// MARK: - Encoding Protocol

protocol DNSRecordEncodable: DNSRecord {

    func encodeAdditionalData(into buffer: inout ByteBufferWriter) throws

}

extension DNSRecordEncodable {

    func encodeSharedValues(into buffer: inout ByteBufferWriter) throws {
        try labels.encode(into: &buffer)
        buffer.write(recordType.rawValue)
        buffer.write(recordClass)
        buffer.write(timeToLive)
    }

}

// MARK: - Concrete Record Types

public struct DNSUnknownRecord: DNSRecord {
    public let labels: DNSLabels
    public let recordType: DNSRecordType
    public let recordClass: UInt16
    public let timeToLive: UInt32
    public let bytes: Data
}

extension DNSUnknownRecord: DNSRecordEncodable {

    func encodeAdditionalData(into buffer: inout ByteBufferWriter) throws {
        buffer.write(UInt16(bytes.count))
        buffer.write(bytes)
    }

}

public struct DNSARecord: DNSRecord {
    public let labels: DNSLabels
    public let recordType: DNSRecordType
    public let recordClass: UInt16
    public let timeToLive: UInt32
    public let ipFragments: [UInt8]
}

extension DNSARecord: DNSRecordEncodable {

    func encodeAdditionalData(into buffer: inout ByteBufferWriter) throws {
        buffer.write(UInt16(ipFragments.count))
        buffer.write(ipFragments)
    }

}
