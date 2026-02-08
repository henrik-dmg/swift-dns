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
        let path = try #require(
            Bundle.module.url(forResource: "query_packet", withExtension: "txt")
        )
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
        let path = try #require(
            Bundle.module.url(forResource: "response_packet", withExtension: "txt")
        )
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
            id: 599,
            operationCode: .inverseQuery,
            isResponse: true,
            isRecursionDesired: false,
            isRecursionAvailable: true,
            isAnswerAuthoritative: true,
            isAuthenticatedData: true,
            queries: [dnsQuery1, dnsQuery2, dnsQuery3],
            records: [dnsRecord1, dnsRecord2, dnsRecord3]
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
            id: 599,
            isResponse: true,
            isRecursionDesired: false,
            queries: [dnsQuery1],
            records: [dnsRecord1]
        )
        let packet2 = DNSPacket(
            id: 599,
            isResponse: true,
            isRecursionDesired: false,
            queries: [dnsQuery1],
            records: [dnsRecord1]
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
            id: 1,
            isRecursionDesired: false,
            records: [dnsRecord1, dnsRecord2]
        )
        let packet2 = DNSPacket(
            id: 1,
            isRecursionDesired: false,
            records: [dnsRecord2, dnsRecord1]
        )

        #expect(packet1 != packet2)
    }

    // MARK: - Public Initializer

    @Test("default flags produce a standard query header")
    func defaultFlags() {
        let packet = DNSPacket()

        #expect(packet.header.operationCode == .query)
        #expect(packet.header.resultCode == .noError)
        #expect(packet.header.isResponse == false)
        #expect(packet.header.isRecursionDesired == true)
        #expect(packet.header.isRecursionAvailable == false)
        #expect(packet.header.isAnswerAuthoritative == false)
        #expect(packet.header.isMessageTruncated == false)
        #expect(packet.header.isCheckingDisabled == false)
        #expect(packet.header.isAuthenticatedData == false)
        #expect(packet.header.z == false)
        #expect(packet.queries.isEmpty)
        #expect(packet.records.isEmpty)
        #expect(packet.authorities.isEmpty)
        #expect(packet.resources.isEmpty)
    }

    @Test("header counts match array lengths")
    func headerCountsMatchArrays() {
        let queries = [
            DNSQuery(labels: ["example", "com"], recordType: .a, recordClass: 1),
            DNSQuery(labels: ["example", "org"], recordType: .aaaa, recordClass: 1),
        ]
        let records: [any DNSRecord] = [
            ARecord(
                labels: DNSLabels(labels: ["example", "com"]),
                recordType: .a,
                recordClass: 1,
                timeToLive: 300,
                address: IPv4Address(93, 184, 216, 34)
            )
        ]

        let packet = DNSPacket(id: 42, queries: queries, records: records)

        #expect(packet.header.numberOfQueries == 2)
        #expect(packet.header.numberOfRecords == 1)
        #expect(packet.header.numberOfAuthorities == 0)
        #expect(packet.header.numberOfResources == 0)
    }

    @Test("custom flags propagate correctly")
    func customFlags() {
        let packet = DNSPacket(
            id: 1234,
            operationCode: .status,
            resultCode: .serverFailure,
            isResponse: true,
            isRecursionDesired: false,
            isRecursionAvailable: true,
            isAnswerAuthoritative: true,
            isMessageTruncated: true,
            isCheckingDisabled: true,
            isAuthenticatedData: true
        )

        #expect(packet.header.id == 1234)
        #expect(packet.header.operationCode == .status)
        #expect(packet.header.resultCode == .serverFailure)
        #expect(packet.header.isResponse == true)
        #expect(packet.header.isRecursionDesired == false)
        #expect(packet.header.isRecursionAvailable == true)
        #expect(packet.header.isAnswerAuthoritative == true)
        #expect(packet.header.isMessageTruncated == true)
        #expect(packet.header.isCheckingDisabled == true)
        #expect(packet.header.isAuthenticatedData == true)
    }

    // MARK: - Response Factory

    @Test("response factory copies request metadata")
    func responseFactory() {
        let request = DNSPacket(
            id: 9999,
            operationCode: .inverseQuery,
            isRecursionDesired: true,
            queries: [DNSQuery(labels: ["example", "com"], recordType: .a, recordClass: 1)]
        )

        let answerRecord = ARecord(
            labels: DNSLabels(labels: ["example", "com"]),
            recordType: .a,
            recordClass: 1,
            timeToLive: 300,
            address: IPv4Address(93, 184, 216, 34)
        )

        let response = request.makeResponse(
            isRecursionAvailable: true,
            isAnswerAuthoritative: true,
            records: [answerRecord]
        )

        // Copied from request
        #expect(response.header.id == 9999)
        #expect(response.header.operationCode == .inverseQuery)
        #expect(response.header.isRecursionDesired == true)
        #expect(response.queries == request.queries)

        // Set by response factory
        #expect(response.header.isResponse == true)
        #expect(response.header.resultCode == .noError)
        #expect(response.header.isRecursionAvailable == true)
        #expect(response.header.isAnswerAuthoritative == true)

        // Counts derived from arrays
        #expect(response.header.numberOfQueries == 1)
        #expect(response.header.numberOfRecords == 1)
        #expect(response.header.numberOfAuthorities == 0)
        #expect(response.header.numberOfResources == 0)
    }

    @Test("response factory with error result code")
    func responseFactoryWithError() {
        let request = DNSPacket(
            id: 42,
            queries: [DNSQuery(labels: ["nonexistent", "example"], recordType: .a, recordClass: 1)]
        )

        let response = request.makeResponse(resultCode: .nonExistentDomain)

        #expect(response.header.id == 42)
        #expect(response.header.isResponse == true)
        #expect(response.header.resultCode == .nonExistentDomain)
        #expect(response.records.isEmpty)
    }

    // MARK: - Round-Trip

    @Test("packet constructed with public init round-trips through encode and decode")
    func publicInitRoundTrip() throws {
        let query = DNSQuery(labels: ["example", "com"], recordType: .a, recordClass: 1)
        let record = ARecord(
            labels: DNSLabels(labels: ["example", "com"]),
            recordType: .a,
            recordClass: 1,
            timeToLive: 300,
            address: IPv4Address(93, 184, 216, 34)
        )

        let original = DNSPacket(
            id: 12345,
            isResponse: true,
            isRecursionDesired: true,
            isRecursionAvailable: true,
            isAnswerAuthoritative: true,
            queries: [query],
            records: [record]
        )

        let encoder = DNSPacketEncoder()
        let data = try encoder.encode(packet: original)

        let decoder = DNSPacketDecoder()
        let decoded = try decoder.decode(from: data)

        #expect(decoded == original)
    }

    @Test("response factory packet round-trips through encode and decode")
    func responseFactoryRoundTrip() throws {
        let request = DNSPacket(
            id: 7777,
            queries: [DNSQuery(labels: ["example", "com"], recordType: .a, recordClass: 1)]
        )

        let record = ARecord(
            labels: DNSLabels(labels: ["example", "com"]),
            recordType: .a,
            recordClass: 1,
            timeToLive: 60,
            address: IPv4Address(10, 0, 0, 1)
        )

        let response = request.makeResponse(
            isRecursionAvailable: true,
            records: [record]
        )

        let encoder = DNSPacketEncoder()
        let data = try encoder.encode(packet: response)

        let decoder = DNSPacketDecoder()
        let decoded = try decoder.decode(from: data)

        #expect(decoded == response)
    }

}
