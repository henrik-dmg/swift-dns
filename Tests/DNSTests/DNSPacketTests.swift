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
            Bundle.module.url(forResource: "query-noedns-google.com-A", withExtension: nil)
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
            Bundle.module.url(forResource: "response-noedns-google.com-A", withExtension: nil)
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
        #expect(firstRecord.address.fragments == [142, 251, 141, 46])
    }

    // MARK: - Encoding

    @Test("encodes packet", arguments: TestResourcesProvider.availableTestResources())
    func encodePacket(packetName: String) throws {
        let path = try #require(Bundle.module.url(forResource: packetName, withExtension: nil))
        let data = try Data(contentsOf: path)
        let decoder = DNSPacketDecoder()
        let packet = try decoder.decode(from: data)

        var encoder = DNSPacketEncoder()
        encoder.shouldCompressLabels = true
        let encodedPacket = try encoder.encode(packet: packet)

        // Write encoded packet to tmp/ directory if environment variable is set
        if ProcessInfo.processInfo.environment["OUTPUT_ENCODED_PACKETS"] != nil {
            let fileManager = FileManager.default
            let currentDirectory = fileManager.currentDirectoryPath
            let tmpDirectory = URL(fileURLWithPath: currentDirectory).appendingPathComponent("tmp")

            // Create tmp directory if it doesn't exist
            try fileManager.createDirectory(at: tmpDirectory, withIntermediateDirectories: true)

            // Write the encoded packet with -verification suffix
            let outputFileName = "\(packetName)-verification"
            let outputPath = tmpDirectory.appendingPathComponent(outputFileName)
            try encodedPacket.write(to: outputPath)
        }

        if encodedPacket != data {
            print(packet.records)
            print(data.hexEncodedString(options: .upperCase))
            print(encodedPacket.hexEncodedString(options: .upperCase))

            let decodedPacket = try decoder.decode(from: encodedPacket)
            #expect(decodedPacket == packet, "Reencoded packet is not equal to input \(packetName)")
        }
    }

    @Test("encodes custom package")
    func encodeCustomPackage() throws {
        let dnsQuery1 = DNSQuery(labels: ["mail", "google", "com"], recordType: .a, recordClass: 1)
        let dnsQuery2 = DNSQuery(labels: ["google", "com"], recordType: .a, recordClass: 1)
        let dnsQuery3 = DNSQuery(labels: ["panhans", "dev"], recordType: .a, recordClass: 1)

        let dnsRecord1 = ARecord(
            labels: DNSLabels(labels: ["mail", "google", "com"]),
            recordClass: 1,
            timeToLive: 100,
            address: IPv4Address(192, 168, 178, 1)
        )
        let dnsRecord2 = ARecord(
            labels: DNSLabels(labels: ["google", "com"]),
            recordClass: 1,
            timeToLive: 100,
            address: IPv4Address(192, 168, 178, 2)
        )
        let dnsRecord3 = ARecord(
            labels: DNSLabels(labels: ["panhans", "dev"]),
            recordClass: 1,
            timeToLive: 100,
            address: IPv4Address(192, 168, 178, 3)
        )

        let packet = try DNSPacket(
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
    func packetsAreEqual() throws {
        let dnsQuery1 = DNSQuery(labels: ["mail", "google", "com"], recordType: .a, recordClass: 1)

        let dnsRecord1 = ARecord(
            labels: DNSLabels(labels: ["mail", "google", "com"]),
            recordClass: 1,
            timeToLive: 100,
            address: IPv4Address(192, 168, 178, 1)
        )

        let packet1 = try DNSPacket(
            id: 599,
            isResponse: true,
            isRecursionDesired: false,
            queries: [dnsQuery1],
            records: [dnsRecord1]
        )
        let packet2 = try DNSPacket(
            id: 599,
            isResponse: true,
            isRecursionDesired: false,
            queries: [dnsQuery1],
            records: [dnsRecord1]
        )

        #expect(packet1 == packet2)
    }

    @Test("packets are not equal")
    func packetsAreNotEqual() throws {
        let dnsRecord1 = ARecord(
            labels: DNSLabels(labels: ["mail", "google", "com"]),
            recordClass: 1,
            timeToLive: 100,
            address: IPv4Address(192, 168, 178, 1)
        )
        let dnsRecord2 = ARecord(
            labels: DNSLabels(labels: ["google", "com"]),
            recordClass: 1,
            timeToLive: 100,
            address: IPv4Address(192, 168, 178, 2)
        )

        let packet1 = try DNSPacket(
            id: 1,
            isRecursionDesired: false,
            records: [dnsRecord1, dnsRecord2]
        )
        let packet2 = try DNSPacket(
            id: 1,
            isRecursionDesired: false,
            records: [dnsRecord2, dnsRecord1]
        )

        #expect(packet1 != packet2)
    }

    // MARK: - Public Initializer

    @Test("default flags produce a standard query header")
    func defaultFlags() throws {
        let packet = try DNSPacket()

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
    func headerCountsMatchArrays() throws {
        let queries = [
            DNSQuery(labels: ["example", "com"], recordType: .a, recordClass: 1),
            DNSQuery(labels: ["example", "org"], recordType: .aaaa, recordClass: 1),
        ]
        let records: [any DNSRecord] = [
            ARecord(
                labels: DNSLabels(labels: ["example", "com"]),
                recordClass: 1,
                timeToLive: 300,
                address: IPv4Address(93, 184, 216, 34)
            )
        ]

        let packet = try DNSPacket(id: 42, queries: queries, records: records)

        #expect(packet.header.numberOfQueries == 2)
        #expect(packet.header.numberOfRecords == 1)
        #expect(packet.header.numberOfAuthorities == 0)
        #expect(packet.header.numberOfResources == 0)
    }

    @Test("custom flags propagate correctly")
    func customFlags() throws {
        let packet = try DNSPacket(
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

    @Test("throws when too many queries provided")
    func tooManyQueries() throws {
        let query = DNSQuery(labels: ["test"], recordType: .a, recordClass: 1)
        let queries = Array(repeating: query, count: Int(UInt16.max) + 1)

        #expect(throws: EncoderError.self) {
            try DNSPacket(queries: queries)
        }
    }

    @Test("throws when resources plus EDNS OPT exceed UInt16.max")
    func tooManyResourcesWithEDNS() throws {
        let record = ARecord(
            labels: DNSLabels(labels: ["example", "com"]),
            recordClass: 1,
            timeToLive: 60,
            address: IPv4Address(1, 2, 3, 4)
        )
        let resources = Array(repeating: record as any DNSRecord, count: Int(UInt16.max))

        #expect(throws: EncoderError.self) {
            try DNSPacket(resources: resources, edns: OPTRecord())
        }
    }

    // MARK: - Response Factory

    @Test("response factory copies request metadata")
    func responseFactory() throws {
        let request = try DNSPacket(
            id: 9999,
            operationCode: .inverseQuery,
            isRecursionDesired: true,
            queries: [DNSQuery(labels: ["example", "com"], recordType: .a, recordClass: 1)]
        )

        let answerRecord = ARecord(
            labels: DNSLabels(labels: ["example", "com"]),
            recordClass: 1,
            timeToLive: 300,
            address: IPv4Address(93, 184, 216, 34)
        )

        let response = try request.makeResponse(
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

    @Test("response factory with EDNS propagation")
    func responseFactoryWithEDNS() throws {
        let request = try DNSPacket(
            id: 42,
            queries: [DNSQuery(labels: ["example", "com"], recordType: .a, recordClass: 1)],
            edns: OPTRecord(udpPayloadSize: 4096)
        )

        let response = try request.makeResponse(
            isRecursionAvailable: true,
            edns: OPTRecord(udpPayloadSize: 1232, dnssecOK: true)
        )

        #expect(response.edns != nil)
        #expect(response.edns?.udpPayloadSize == 1232)
        #expect(response.edns?.dnssecOK == true)
    }

    @Test("response factory with error result code")
    func responseFactoryWithError() throws {
        let request = try DNSPacket(
            id: 42,
            queries: [DNSQuery(labels: ["nonexistent", "example"], recordType: .a, recordClass: 1)]
        )

        let response = try request.makeResponse(resultCode: .nonExistentDomain)

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
            recordClass: 1,
            timeToLive: 300,
            address: IPv4Address(93, 184, 216, 34)
        )

        let original = try DNSPacket(
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

    @Test("packet with EDNS round-trips through encode and decode")
    func ednsRoundTrip() throws {
        let query = DNSQuery(labels: ["example", "com"], recordType: .a, recordClass: 1)
        let record = ARecord(
            labels: DNSLabels(labels: ["example", "com"]),
            recordClass: 1,
            timeToLive: 300,
            address: IPv4Address(93, 184, 216, 34)
        )

        let edns = OPTRecord(udpPayloadSize: 4096, dnssecOK: true)

        let original = try DNSPacket(
            id: 54321,
            isResponse: true,
            isRecursionDesired: true,
            isRecursionAvailable: true,
            queries: [query],
            records: [record],
            edns: edns
        )

        let encoder = DNSPacketEncoder()
        let data = try encoder.encode(packet: original)

        let decoder = DNSPacketDecoder()
        let decoded = try decoder.decode(from: data)

        #expect(decoded == original)
        #expect(decoded.edns != nil)
        #expect(decoded.edns?.udpPayloadSize == 4096)
        #expect(decoded.edns?.dnssecOK == true)
    }

    @Test("packet with EDNS options round-trips through encode and decode")
    func ednsWithOptionsRoundTrip() throws {
        let cookie = CookieOption(
            clientCookie: Data(repeating: 0xAB, count: 8),
            serverCookie: Data(repeating: 0xCD, count: 16)
        )
        let edns = OPTRecord(udpPayloadSize: 1232, options: [cookie])

        let original = try DNSPacket(
            id: 11111,
            queries: [DNSQuery(labels: ["example", "com"], recordType: .a, recordClass: 1)],
            edns: edns
        )

        let encoder = DNSPacketEncoder()
        let data = try encoder.encode(packet: original)

        let decoder = DNSPacketDecoder()
        let decoded = try decoder.decode(from: data)

        #expect(decoded == original)
        #expect(decoded.edns?.options.count == 1)
    }

    @Test("header numberOfResources includes EDNS OPT record")
    func headerResourceCountIncludesEDNS() throws {
        let record = ARecord(
            labels: DNSLabels(labels: ["example", "com"]),
            recordClass: 1,
            timeToLive: 300,
            address: IPv4Address(1, 2, 3, 4)
        )

        let packet = try DNSPacket(
            id: 1,
            resources: [record],
            edns: OPTRecord()
        )

        // 1 regular resource + 1 OPT record
        #expect(packet.header.numberOfResources == 2)
        #expect(packet.resources.count == 1)
    }

    @Test("extendedResultCode returns header RCODE when no EDNS")
    func extendedResultCodeWithoutEDNS() throws {
        let packet = try DNSPacket(resultCode: .serverFailure)
        #expect(packet.extendedResultCode == UInt16(DNSResultCode.serverFailure.rawValue))
    }

    @Test("extendedResultCode combines header and EDNS RCODE")
    func extendedResultCodeWithEDNS() throws {
        let packet = try DNSPacket(
            resultCode: .noError,
            edns: OPTRecord(extendedRCODE: 1)
        )
        // Combined: (1 << 4) | 0 = 16 which is BADVERS
        #expect(packet.extendedResultCode == 16)
    }

    @Test("extendedResultCode for badVersion with OPT extendedRCODE 1 equals 16")
    func extendedResultCodeBadVersionWithOPT() throws {
        // badVersion rawValue = 16, low nibble = 0; extendedRCODE = 1
        // (1 << 4) | 0 = 16
        let packet = try DNSPacket(resultCode: .badVersion, edns: OPTRecord(extendedRCODE: 1))
        #expect(packet.extendedResultCode == 16)
    }

    @Test("extendedResultCode for badVersion without OPT returns low nibble only")
    func extendedResultCodeBadVersionWithoutOPT() throws {
        // badVersion rawValue = 16, low nibble = 0x0F & 16 = 0
        let packet = try DNSPacket(resultCode: .badVersion)
        #expect(packet.extendedResultCode == 0)
    }

    @Test("extendedResultCode for badCookie with OPT extendedRCODE 1 equals 23")
    func extendedResultCodeBadCookieWithOPT() throws {
        // badCookie rawValue = 23, low nibble = 7; extendedRCODE = 1
        // (1 << 4) | 7 = 23
        let packet = try DNSPacket(resultCode: .badCookie, edns: OPTRecord(extendedRCODE: 1))
        #expect(packet.extendedResultCode == 23)
    }

    @Test("packet without EDNS has nil edns property")
    func noEDNSPacket() throws {
        let packet = try DNSPacket(id: 1)
        #expect(packet.edns == nil)
    }

    @Test("response factory packet round-trips through encode and decode")
    func responseFactoryRoundTrip() throws {
        let request = try DNSPacket(
            id: 7777,
            queries: [DNSQuery(labels: ["example", "com"], recordType: .a, recordClass: 1)]
        )

        let record = ARecord(
            labels: DNSLabels(labels: ["example", "com"]),
            recordClass: 1,
            timeToLive: 60,
            address: IPv4Address(10, 0, 0, 1)
        )

        let response = try request.makeResponse(
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
