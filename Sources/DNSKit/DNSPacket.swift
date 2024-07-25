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
    public let records: [DNSRecord]
    public let authorities: [DNSRecord]
    public let resources: [DNSRecord]

}

// MARK: - Decoding

extension DNSPacket {

    public static func decode(from data: Data) throws -> DNSPacket {
        var byteBuffer = ByteBufferReader(data)

        let header = try DNSHeader.decode(from: &byteBuffer)

        var queries: [DNSQuery] = []
        for _ in 0 ..< header.numberOfQueries {
            let query = try DNSQuery.decode(from: &byteBuffer)
            queries.append(query)
        }

        var records: [DNSRecord] = []
        for _ in 0 ..< header.numberOfRecords {
            let record = try DNSRecordDecoder.decode(from: &byteBuffer)
            records.append(record)
        }

        var authorities: [DNSRecord] = []
        for _ in 0 ..< header.numberOfAuthorities {
            let record = try DNSRecordDecoder.decode(from: &byteBuffer)
            authorities.append(record)
        }

        var resources: [DNSRecord] = []
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

    enum EncoderError: LocalizedError {
        case unencodableRecordFound(record: DNSRecord)
    }

    public func encode() throws -> Data {
        var byteBuffer = ByteBufferWriter()

        try header.encode(into: &byteBuffer)

        for query in queries {
            try query.encode(into: &byteBuffer)
        }

        try encodeRecords(records, into: &byteBuffer)
        try encodeRecords(authorities, into: &byteBuffer)
        try encodeRecords(resources, into: &byteBuffer)

        return byteBuffer.data
    }

    private func encodeRecords(_ records: [DNSRecord], into byteBuffer: inout ByteBufferWriter) throws {
        for record in records {
            guard let encodableRecord = record as? DNSRecordEncodable else {
                throw EncoderError.unencodableRecordFound(record: record)
            }
            try encodableRecord.encodeSharedValues(into: &byteBuffer)
            try encodableRecord.encodeAdditionalData(into: &byteBuffer)
        }
    }

}
