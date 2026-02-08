//
//  DNSPacketTests.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation
import Testing

@testable import DNS

@Suite
struct DNSPacketTests {

    // MARK: - Decoding

    @Test("decodes query packet")
    func decodeQueryPacket() throws {
        let path = try #require(Bundle.module.url(forResource: "query_packet", withExtension: "txt"))
        let data = try Data(contentsOf: path)
        let decoder = DNSPacketDecoder()
        let packet = try decoder.decode(from: data)

        #expect(packet.header.numberOfQueries == 1)
        #expect(packet.queries.count == 1)
        #expect(packet.header.numberOfRecords == 0)
        #expect(!packet.header.isResponse)

        let firstQuery = try #require(packet.queries.first)
        #expect(firstQuery.labels.labels == ["google", "com"])
    }

    @Test("decodes response packet")
    func decodeResponsePacket() throws {
        let path = try #require(Bundle.module.url(forResource: "response_packet", withExtension: "txt"))
        let data = try Data(contentsOf: path)
        let decoder = DNSPacketDecoder()
        let packet = try decoder.decode(from: data)

        #expect(packet.header.numberOfQueries == 1)
        #expect(packet.queries.count == 1)
        #expect(packet.header.numberOfRecords == 1)
        #expect(packet.header.isResponse)

        let firstQuery = try #require(packet.queries.first)
        #expect(firstQuery.labels.labels == ["google", "com"])

        let firstRecord = try #require(packet.records.first as? ARecord)
        #expect(firstRecord.recordType == .a)
        #expect(firstRecord.labels.labels == ["google", "com"])
        #expect(firstRecord.address.fragments == [216, 58, 215, 78])
    }

    // MARK: - Encoding

    @Test(
        "encodes packet",
        arguments: [
            "query_packet", "query_packet_big", "query_packet_aaaa", "query_packet_mixed",
            "query_packet_txt",
            "response_packet", "response_packet_big", "response_packet_aaaa",
            "response_packet_mixed",
            "response_packet_txt",
        ]
    )
    func encodePacket(packetName: String) throws {
        let path = try #require(Bundle.module.url(forResource: packetName, withExtension: "txt"))
        let data = try Data(contentsOf: path)
        let decoder = DNSPacketDecoder()
        let packet = try decoder.decode(from: data)

        var encoder = DNSPacketEncoder()
        encoder.shouldCompressLabels = true
        let encodedPacket = try encoder.encode(packet: packet)

        #expect(encodedPacket == data)
        print(packet.records)
        if encodedPacket != data {
            print(data.hexEncodedString(options: .upperCase))
            print(encodedPacket.hexEncodedString(options: .upperCase))
        }
    }

    @Test("encodes custom package")
    func encodeCustomPackage() throws {
        let dnsQuery1 = DNSQuery(labels: ["mail", "google", "com"], recordType: .a, recordClass: 1)
        let dnsQuery2 = DNSQuery(labels: ["google", "com"], recordType: .a, recordClass: 1)
        let dnsQuery3 = DNSQuery(labels: ["panhans", "dev"], recordType: .a, recordClass: 1)

        let dnsRecord1 = ARecord(
            labels: DNSLabels(labels: ["mail", "google", "com"]),
            recordType: .a,
            recordClass: 1,
            timeToLive: 100,
            address: IPv4Address(192, 168, 178, 1)
        )
        let dnsRecord2 = ARecord(
            labels: DNSLabels(labels: ["google", "com"]),
            recordType: .a,
            recordClass: 1,
            timeToLive: 100,
            address: IPv4Address(192, 168, 178, 2)
        )
        let dnsRecord3 = ARecord(
            labels: DNSLabels(labels: ["panhans", "dev"]),
            recordType: .a,
            recordClass: 1,
            timeToLive: 100,
            address: IPv4Address(192, 168, 178, 3)
        )

        let packet = DNSPacket(
            header: .mock,
            queries: [dnsQuery1, dnsQuery2, dnsQuery3],
            records: [dnsRecord1, dnsRecord2, dnsRecord3],
            authorities: [],
            resources: []
        )

        // Test uncompressed encoding
        var uncompressedEncoder = DNSPacketEncoder()
        uncompressedEncoder.shouldCompressLabels = false
        let uncompressedPacketData = try uncompressedEncoder.encode(packet: packet)

        // Test compressed encoding
        var compressedEncoder = DNSPacketEncoder()
        compressedEncoder.shouldCompressLabels = true
        let compressedPacketData = try compressedEncoder.encode(packet: packet)

        // Should be smaller because google.com occurs multiple times in the packet,
        // so with compression it should not be written multiple times but rather use a jump directive.
        #expect(compressedPacketData.count < uncompressedPacketData.count)

        let decoder = DNSPacketDecoder()
        let uncompressedDecodedPacket = try decoder.decode(from: uncompressedPacketData)
        let compressedDecodedPacket = try decoder.decode(from: compressedPacketData)

        #expect(uncompressedDecodedPacket == compressedDecodedPacket)
    }

    @Test("packets are equal")
    func packetsAreEqual() {
        let dnsQuery1 = DNSQuery(labels: ["mail", "google", "com"], recordType: .a, recordClass: 1)

        let dnsRecord1 = ARecord(
            labels: DNSLabels(labels: ["mail", "google", "com"]),
            recordType: .a,
            recordClass: 1,
            timeToLive: 100,
            address: IPv4Address(192, 168, 178, 1)
        )

        let packet1 = DNSPacket(
            header: .mock,
            queries: [dnsQuery1],
            records: [dnsRecord1],
            authorities: [],
            resources: []
        )
        let packet2 = DNSPacket(
            header: .mock,
            queries: [dnsQuery1],
            records: [dnsRecord1],
            authorities: [],
            resources: []
        )

        #expect(packet1 == packet2)
    }

    @Test("packets are not equal")
    func packetsAreNotEqual() {
        let dnsRecord1 = ARecord(
            labels: DNSLabels(labels: ["mail", "google", "com"]),
            recordType: .a,
            recordClass: 1,
            timeToLive: 100,
            address: IPv4Address(192, 168, 178, 1)
        )
        let dnsRecord2 = ARecord(
            labels: DNSLabels(labels: ["google", "com"]),
            recordType: .a,
            recordClass: 1,
            timeToLive: 100,
            address: IPv4Address(192, 168, 178, 2)
        )

        let packet1 = DNSPacket(
            header: .mock,
            queries: [],
            records: [dnsRecord1, dnsRecord2],
            authorities: [],
            resources: []
        )
        let packet2 = DNSPacket(
            header: .mock,
            queries: [],
            records: [dnsRecord2, dnsRecord1],
            authorities: [],
            resources: []
        )

        #expect(packet1 != packet2)
    }

}

extension DNSHeader {

    static let mock = DNSHeader(
        id: 599,
        isRecursionDesired: false,
        isMessageTruncated: false,
        isAnswerAuthorative: true,
        isCheckingDisabled: false,
        isAuthenticatedData: true,
        isRecursionAvailable: true,
        isResponse: true,
        operationCode: .inverseQuery,
        resultCode: .noError,
        z: false,
        numberOfQueries: 3,
        numberOfRecords: 3,
        numberOfAuthorities: 0,
        numberOfResources: 0
    )

}
