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
        var byteBuffer: any ByteBufferReading = ByteBufferReader(data)

        let header = try DNSHeader.decode(from: &byteBuffer)

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
