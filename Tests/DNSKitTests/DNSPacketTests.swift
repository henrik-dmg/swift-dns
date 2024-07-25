//
//  DNSPacketTests.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation
import Testing

@testable import DNSKit

@Suite
struct DNSPacketTests {

    @Test
    func decodeQueryPacket() throws {
        let path = try #require(Bundle.module.url(forResource: "query_packet", withExtension: "txt"))
        let data = try Data(contentsOf: path)
        let packet = try DNSPacket.decode(from: data)

        #expect(packet.header.numberOfQueries == 1)
        #expect(packet.queries.count == 1)
        #expect(packet.header.numberOfRecords == 0)
        #expect(!packet.header.isResponse)

        let firstQuery = try #require(packet.queries.first)
        #expect(firstQuery.labels.labels == ["google", "com"])
    }

    @Test
    func encodeQueryPacket() throws {
        let path = try #require(Bundle.module.url(forResource: "query_packet", withExtension: "txt"))
        let data = try Data(contentsOf: path)
        let packet = try DNSPacket.decode(from: data)
        let encodedPacket = try packet.encode()

        #expect(encodedPacket == data)
    }

    @Test
    func decodeResponsePacket() throws {
        let path = try #require(Bundle.module.url(forResource: "response_packet", withExtension: "txt"))
        let data = try Data(contentsOf: path)
        let packet = try DNSPacket.decode(from: data)

        #expect(packet.header.numberOfQueries == 1)
        #expect(packet.queries.count == 1)
        #expect(packet.header.numberOfRecords == 1)
        #expect(packet.header.isResponse)

        let firstQuery = try #require(packet.queries.first)
        #expect(firstQuery.labels.labels == ["google", "com"])

        let firstRecord = try #require(packet.records.first as? DNSARecord)
        #expect(firstRecord.labels.labels == ["google", "com"])
        #expect(firstRecord.ipFragments == [216, 58, 215, 78])
    }

}
