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

    // MARK: - Decoding

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
        #expect(firstRecord.recordType == .A(1))
        #expect(firstRecord.labels.labels == ["google", "com"])
        #expect(firstRecord.ipFragments == [216, 58, 215, 78])
    }

    // MARK: - Encoding

    @Test(arguments: [
        "query_packet",
        "query_packet_big",
        "query_packet_aaaa",
        "response_packet",
        "response_packet_big",
        "response_packet_aaaa",
    ])
    func encodePacket(packetName: String) throws {
        let path = try #require(Bundle.module.url(forResource: packetName, withExtension: "txt"))
        let data = try Data(contentsOf: path)
        let packet = try DNSPacket.decode(from: data)
        let encodedPacket = try packet.encode()
        let packet2 = try DNSPacket.decode(from: encodedPacket)
        let encodedPacket2 = try packet2.encode()

        #expect(encodedPacket == data)
        #expect(encodedPacket2 == data)
    }

}
