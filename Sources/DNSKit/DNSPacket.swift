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

    // MARK: - DNSPacketDecodable

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
