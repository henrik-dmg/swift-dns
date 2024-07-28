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
        try recordType.encode(into: &buffer)
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

public struct DNSARecord: DNSRecord, CustomDebugStringConvertible {

    public let labels: DNSLabels
    public let recordType: DNSRecordType
    public let recordClass: UInt16
    public let timeToLive: UInt32
    public let address: IPv4Address

    public var lengthOfCustomData: UInt16 {
        4  // IPv4 addresses have 4 octets
    }

    public func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws {
        try address.encode(into: &buffer)
    }

    public var debugDescription: String {
        "A(\(labels.labels), class \(recordClass), TTL \(timeToLive), IP: \(address))"
    }

}

// MARK: - AAAA Record

public struct DNSAAAARecord: DNSRecord, CustomDebugStringConvertible {

    public let labels: DNSLabels
    public let recordType: DNSRecordType
    public let recordClass: UInt16
    public let timeToLive: UInt32
    public let address: IPv6Address

    public var lengthOfCustomData: UInt16 {
        16  // IPv6 addresses have 16 octets
    }

    public func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws {
        try address.encode(into: &buffer)
    }

    public var debugDescription: String {
        "AAAA(\(labels.labels), class \(recordClass), TTL \(timeToLive), IP: \(address))"
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

// MARK: - TXT Record

public struct DNSTXTRecord: DNSRecord {

    public let labels: DNSLabels
    public let recordType: DNSRecordType
    public let recordClass: UInt16
    public let timeToLive: UInt32
    public let lengthOfCustomData: UInt16
    public let lengthOfString: UInt8
    public let content: String

    public func encodeAdditionalData(into buffer: inout ByteBufferWriting) throws {
        buffer.write(lengthOfString)
        guard let contentData = content.data(using: .ascii) else {
            throw EncoderError.cantConvertStringToData(content)
        }
        buffer.write(contentData)
    }

}
