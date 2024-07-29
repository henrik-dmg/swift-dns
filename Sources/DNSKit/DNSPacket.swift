//
//  DNSPacket.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

public struct DNSPacket {

    public let header: DNSHeader
    public let queries: [DNSQuery]
    public let records: [any DNSRecord]
    public let authorities: [any DNSRecord]
    public let resources: [any DNSRecord]

}

// MARK: - Decoding

extension DNSPacket {

    public static func decode(from data: Data) throws -> DNSPacket {
        print(data.hexEncodedString())

        var byteBuffer: any ByteBufferReading = ByteBufferReader(data)

        let header = try DNSHeader.decode(from: &byteBuffer)

        print(header)

        var queries: [DNSQuery] = []
        print("Decoding \(header.numberOfQueries) queries")
        for _ in 0 ..< header.numberOfQueries {
            let query = try DNSQuery.decode(from: &byteBuffer)
            queries.append(query)
        }

        var records: [any DNSRecord] = []
        print("Decoding \(header.numberOfRecords) records")
        for _ in 0 ..< header.numberOfRecords {
            print("Decoding record")
            let record = try DNSRecordDecoder.decode(from: &byteBuffer)
            records.append(record)
        }

        var authorities: [any DNSRecord] = []
        print("Decoding \(header.numberOfAuthorities) authorities")
        for _ in 0 ..< header.numberOfAuthorities {
            print("Decoding authority")
            let record = try DNSRecordDecoder.decode(from: &byteBuffer)
            authorities.append(record)
        }

        var resources: [any DNSRecord] = []
        print("Decoding \(header.numberOfResources) resources")
        for _ in 0 ..< header.numberOfResources {
            print("Decoding resource")
            let record = try DNSRecordDecoder.decode(from: &byteBuffer)
            resources.append(record)
        }

        if byteBuffer.currentIndex < data.count {
            print("ByteBuffer has parsed \(byteBuffer.currentIndex)/\(data.count) bytes")
        }

        return DNSPacket(header: header, queries: queries, records: records, authorities: authorities, resources: resources)
    }

}

// MARK: - Encoding

extension DNSPacket {

    public func encode(compressLabels: Bool = true) throws -> Data {
        var byteBuffer: any ByteBufferWriting = compressLabels ? DNSPacketCompressor() : ByteBufferWriter()

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
            return areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: DNSUnknownRecord.self)
        case .A:
            return areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: DNSARecord.self)
        case .AAAA:
            return areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: DNSAAAARecord.self)
        case .NS:
            return areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: DNSNSRecord.self)
        case .CNAME:
            return areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: DNSCNAMERecord.self)
        case .MX:
            return areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: DNSMXRecord.self)
        case .SOA:
            return areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: DNSUnknownRecord.self)
        case .TXT:
            return areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: DNSTXTRecord.self)
        }
    }

    private static func areRecordsOfTypeEqual<Record: DNSRecord>(lhs: any DNSRecord, rhs: any DNSRecord, type: Record.Type) -> Bool {
        guard let castedLHS = lhs as? Record, let castedRHS = rhs as? Record else {
            return false
        }
        return castedLHS == castedRHS
    }

}
