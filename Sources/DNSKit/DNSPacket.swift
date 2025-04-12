//
//  DNSPacket.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation
import Logging

/// Represents a complete DNS message packet as defined in RFC 1035.
/// A DNS packet consists of five main sections:
/// 1. Header - Contains control information about the message
/// 2. Question - Contains the queries being made
/// 3. Answer - Contains the resource records answering the queries
/// 4. Authority - Contains name server resource records
/// 5. Additional - Contains additional resource records
public struct DNSPacket {

    /// The header section of the DNS message, containing control information.
    public var header: DNSHeader

    /// The question section of the DNS message, containing the queries being made.
    public var queries: [DNSQuery]

    /// The answer section of the DNS message, containing resource records that answer the queries.
    public var records: [any DNSRecord]

    /// The authority section of the DNS message, containing name server resource records.
    public var authorities: [any DNSRecord]

    /// The additional section of the DNS message, containing additional resource records.
    public var resources: [any DNSRecord]

}

// MARK: - Decoding

extension DNSPacket {

    /// Decodes a DNS packet from raw data.
    /// The decoding process follows the DNS message format:
    /// 1. Decodes the header section
    /// 2. Decodes the question section based on the number of queries in the header
    /// 3. Decodes the answer section based on the number of records in the header
    /// 4. Decodes the authority section based on the number of authorities in the header
    /// 5. Decodes the additional section based on the number of resources in the header
    ///
    /// - Parameter data: The raw data containing the DNS message
    /// - Returns: A decoded DNSPacket instance
    /// - Throws: An error if the data cannot be properly decoded
    public static func decode(from data: Data) throws -> DNSPacket {
        Logger.dns.debug("Received \(data.hexEncodedString())")

        var byteBuffer: any ByteBufferReading = ByteBufferReader(data)

        // Decode the header section
        let header = try DNSHeader.decode(from: &byteBuffer)
        Logger.dns.debug("\(header)")

        // Decode the question section
        var queries: [DNSQuery] = []
        for _ in 0 ..< header.numberOfQueries {
            let query = try DNSQuery.decode(from: &byteBuffer)
            queries.append(query)
        }

        // Decode the answer section
        var records: [any DNSRecord] = []
        for _ in 0 ..< header.numberOfRecords {
            let record = try DNSRecordDecoder.decode(from: &byteBuffer)
            records.append(record)
        }

        // Decode the authority section
        var authorities: [any DNSRecord] = []
        for _ in 0 ..< header.numberOfAuthorities {
            let record = try DNSRecordDecoder.decode(from: &byteBuffer)
            authorities.append(record)
        }

        // Decode the additional section
        var resources: [any DNSRecord] = []
        for _ in 0 ..< header.numberOfResources {
            let record = try DNSRecordDecoder.decode(from: &byteBuffer)
            resources.append(record)
        }

        Logger.dns.debug("ByteBuffer has parsed \(byteBuffer.currentIndex)/\(data.count) bytes")

        return DNSPacket(
            header: header,
            queries: queries,
            records: records,
            authorities: authorities,
            resources: resources
        )
    }
}

// MARK: - Encoding

extension DNSPacket {

    /// Encodes the DNS packet into raw data.
    /// The encoding process follows the DNS message format and can optionally use label compression
    /// to reduce the size of the message by avoiding repetition of domain names.
    ///
    /// - Parameter compressLabels: Whether to use DNS label compression (default: true)
    /// - Returns: The encoded DNS message as raw data
    /// - Throws: An error if the packet cannot be properly encoded
    public func encode(compressLabels: Bool = true) throws -> Data {
        // Use a compressor if label compression is enabled
        var byteBuffer: any ByteBufferWriting = compressLabels ? DNSPacketCompressor() : ByteBufferWriter()

        // Encode each section in order
        try header.encode(into: &byteBuffer)

        for query in queries { try query.encode(into: &byteBuffer) }
        for record in records { try record.encode(into: &byteBuffer) }
        for authority in authorities { try authority.encode(into: &byteBuffer) }
        for resource in resources { try resource.encode(into: &byteBuffer) }

        return byteBuffer.data
    }

}

// MARK: - Equatable

extension DNSPacket: Equatable {

    /// Compares two DNS packets for equality.
    /// Two packets are considered equal if all their sections (header, queries, records, authorities, and resources)
    /// are equal in both content and order.
    public static func == (lhs: DNSPacket, rhs: DNSPacket) -> Bool {
        let headersEqual = lhs.header == rhs.header
        let queriesEqual = lhs.queries == rhs.queries

        guard headersEqual && queriesEqual else { return false }

        guard areRecordArraysEqual(lhs: lhs.records, rhs: rhs.records) else { return false }

        guard areRecordArraysEqual(lhs: lhs.authorities, rhs: rhs.authorities) else { return false }

        return areRecordArraysEqual(lhs: lhs.resources, rhs: rhs.resources)
    }

    /// Compares two arrays of DNS records for equality.
    /// The arrays must have the same length and each record at the same index must be equal.
    private static func areRecordArraysEqual(lhs: [any DNSRecord], rhs: [any DNSRecord]) -> Bool {
        guard lhs.count == rhs.count else { return false }

        for (index, record) in lhs.enumerated() {
            let otherRecord = rhs[index]
            if !areRecordsEqual(lhs: record, rhs: otherRecord) { return false }
        }

        return true
    }

    /// Compares two DNS records for equality.
    /// The records must be of the same type and have equal content.
    private static func areRecordsEqual(lhs: any DNSRecord, rhs: any DNSRecord) -> Bool {
        guard lhs.recordType == rhs.recordType else { return false }

        // Compare records based on their specific type
        switch lhs.recordType {
        case .unknown: return areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: UnknownRecord.self)
        case .A: return areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: ARecord.self)
        case .AAAA: return areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: AAAARecord.self)
        case .NS: return areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: NSRecord.self)
        case .CNAME: return areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: CNAMERecord.self)
        case .MX: return areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: MXRecord.self)
        case .SOA: return areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: UnknownRecord.self)
        case .TXT: return areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: TXTRecord.self)
        }
    }

    /// Compares two DNS records of the same specific type for equality.
    private static func areRecordsOfTypeEqual<Record: DNSRecord>(
        lhs: any DNSRecord,
        rhs: any DNSRecord,
        type: Record.Type
    ) -> Bool {
        guard let castedLHS = lhs as? Record, let castedRHS = rhs as? Record else { return false }
        return castedLHS == castedRHS
    }

}
