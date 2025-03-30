//
//  DNSPacket.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation
import Logging

public struct DNSPacket {

    public var header: DNSHeader
    public var queries: [DNSQuery]
    public var records: [any DNSRecord]
    public var authorities: [any DNSRecord]
    public var resources: [any DNSRecord]

}

// MARK: - Decoding

extension DNSPacket {

    public static func decode(from data: Data) throws -> DNSPacket {
        Logger.dns.debug("Received \(data.hexEncodedString())")

        var byteBuffer: any ByteBufferReading = ByteBufferReader(data)

        let header = try DNSHeader.decode(from: &byteBuffer)

        Logger.dns.debug("\(header)")

        var queries: [DNSQuery] = []
        for _ in 0 ..< header.numberOfQueries {
            let query = try DNSQuery.decode(from: &byteBuffer)
            queries.append(query)
        }

        var records: [any DNSRecord] = []
        for _ in 0 ..< header.numberOfRecords {
            let record = try DNSRecordDecoder.decode(from: &byteBuffer)
            records.append(record)
        }

        var authorities: [any DNSRecord] = []
        for _ in 0 ..< header.numberOfAuthorities {
            let record = try DNSRecordDecoder.decode(from: &byteBuffer)
            authorities.append(record)
        }

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

    public func encode(compressLabels: Bool = true) throws -> Data {
        var byteBuffer: any ByteBufferWriting =
            compressLabels ? DNSPacketCompressor() : ByteBufferWriter()

        try header.encode(into: &byteBuffer)

        for query in queries {
            try query.encode(into: &byteBuffer)
        }
        for record in records {
            try record.encode(into: &byteBuffer)
        }
        for authority in authorities {
            try authority.encode(into: &byteBuffer)
        }
        for resource in resources {
            try resource.encode(into: &byteBuffer)
        }

        return byteBuffer.data
    }

}

extension DNSPacket: Equatable {

    public static func == (lhs: DNSPacket, rhs: DNSPacket) -> Bool {
        let headersEqual = lhs.header == rhs.header
        let queriesEqual = lhs.queries == rhs.queries

        guard headersEqual && queriesEqual else {
            return false
        }

        guard areRecordArraysEqual(lhs: lhs.records, rhs: rhs.records) else {
            return false
        }

        guard areRecordArraysEqual(lhs: lhs.authorities, rhs: rhs.authorities) else {
            return false
        }

        return areRecordArraysEqual(lhs: lhs.resources, rhs: rhs.resources)
    }

    private static func areRecordArraysEqual(lhs: [any DNSRecord], rhs: [any DNSRecord]) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }

        for (index, record) in lhs.enumerated() {
            let otherRecord = rhs[index]
            if !areRecordsEqual(lhs: record, rhs: otherRecord) {
                return false
            }
        }

        return true
    }

    private static func areRecordsEqual(lhs: any DNSRecord, rhs: any DNSRecord) -> Bool {
        guard lhs.recordType == rhs.recordType else {
            return false
        }

        switch lhs.recordType {
        case .unknown:
            return areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: UnknownRecord.self)
        case .A:
            return areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: ARecord.self)
        case .AAAA:
            return areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: AAAARecord.self)
        case .NS:
            return areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: NSRecord.self)
        case .CNAME:
            return areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: CNAMERecord.self)
        case .MX:
            return areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: MXRecord.self)
        case .SOA:
            return areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: UnknownRecord.self)
        case .TXT:
            return areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: TXTRecord.self)
        }
    }

    private static func areRecordsOfTypeEqual<Record: DNSRecord>(
        lhs: any DNSRecord,
        rhs: any DNSRecord,
        type: Record.Type
    ) -> Bool {
        guard let castedLHS = lhs as? Record, let castedRHS = rhs as? Record else {
            return false
        }
        return castedLHS == castedRHS
    }

}
