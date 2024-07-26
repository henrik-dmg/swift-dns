//
//  DNSRecord.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

// MARK: - Base Protocol

public protocol DNSRecord: Equatable, Sendable {

    var labels: DNSLabels { get }
    var recordType: DNSRecordType { get }
    var recordClass: UInt16 { get }
    var timeToLive: UInt32 { get }
    var lengthOfCustomData: UInt16 { get }

    func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws

}

extension DNSRecord {

    func encode(into buffer: inout ByteBufferWriting) throws {
        try encodeSharedValues(into: &buffer)
        try encodeAdditionalData(into: &buffer)
    }

    func encodeSharedValues(into buffer: inout ByteBufferWriting) throws {
        try labels.encode(into: &buffer)
        buffer.write(recordType.rawValue)
        buffer.write(recordClass)
        buffer.write(timeToLive)
        buffer.write(lengthOfCustomData)
    }

}

// MARK: - Unknown Record Type

public struct DNSUnknownRecord: DNSRecord {

    public let labels: DNSLabels
    public let recordType: DNSRecordType
    public let recordClass: UInt16
    public let timeToLive: UInt32
    public let lengthOfCustomData: UInt16
    public let bytes: Data

    public func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws {
        buffer.write(bytes)
    }

}

// MARK: - A Record

public struct DNSARecord: DNSRecord {

    public let labels: DNSLabels
    public let recordType: DNSRecordType
    public let recordClass: UInt16
    public let timeToLive: UInt32
    public let lengthOfCustomData: UInt16
    public let ipFragments: [UInt8]

    public func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws {
        buffer.write(ipFragments)
    }

}

// MARK: - NS Record

public struct DNSNSRecord: DNSRecord {

    public let labels: DNSLabels
    public let recordType: DNSRecordType
    public let recordClass: UInt16
    public let timeToLive: UInt32
    public let lengthOfCustomData: UInt16
    public let paylodLabels: DNSLabels

    public func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws {
        try paylodLabels.encode(into: &buffer)
    }

}

// MARK: - CNAME Record

public struct DNSCNAMERecord: DNSRecord {

    public let labels: DNSLabels
    public let recordType: DNSRecordType
    public let recordClass: UInt16
    public let timeToLive: UInt32
    public let lengthOfCustomData: UInt16
    public let paylodLabels: DNSLabels

    public func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws {
        try paylodLabels.encode(into: &buffer)
    }

}

// MARK: - MX Record

public struct DNSMXRecord: DNSRecord {

    public let labels: DNSLabels
    public let recordType: DNSRecordType
    public let recordClass: UInt16
    public let timeToLive: UInt32
    public let lengthOfCustomData: UInt16
    public let priority: UInt16
    public let paylodLabels: DNSLabels

    public func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws {
        buffer.write(priority)
        try paylodLabels.encode(into: &buffer)
    }

}

// MARK: - AAAA Record

public struct DNSAAAARecord: DNSRecord {

    public let labels: DNSLabels
    public let recordType: DNSRecordType
    public let recordClass: UInt16
    public let timeToLive: UInt32
    public let lengthOfCustomData: UInt16
    public let ipFragments: [UInt8]

    public func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws {
        buffer.write(ipFragments)
    }

}
