//
//  DNSRecordDecoderTests.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation
import Testing

@testable import DNS

@Suite
struct DNSRecordDecoderTests {

    // MARK: - NS/CNAME/MX Record Decoding

    @Test("decodes NS record with correct payload labels")
    func decodeNSRecord() throws {
        // This test verifies that NS records correctly decode the nameserver domain
        // from the record's RDATA, not from beyond the record data.
        //
        // Structure of an NS record:
        // - Name: "example.com"
        // - Type: 2 (NS)
        // - Class: 1 (IN)
        // - TTL: 300
        // - RDLENGTH: length of nameserver domain
        // - RDATA: "ns1.example.com" (the nameserver domain)

        var data = Data()

        // Record name: "example.com"
        data.append(contentsOf: [0x07])  // length 7
        data.append(contentsOf: "example".data(using: .ascii)!)
        data.append(contentsOf: [0x03])  // length 3
        data.append(contentsOf: "com".data(using: .ascii)!)
        data.append(contentsOf: [0x00])  // null terminator

        // Type: NS (2)
        data.append(contentsOf: [0x00, 0x02])

        // Class: IN (1)
        data.append(contentsOf: [0x00, 0x01])

        // TTL: 300 (0x0000012C)
        data.append(contentsOf: [0x00, 0x00, 0x01, 0x2C])

        // RDLENGTH: length of "ns1.example.com" = 17 bytes
        // 0x03 "ns1" 0x07 "example" 0x03 "com" 0x00 = 1+3+1+7+1+3+1 = 17
        data.append(contentsOf: [0x00, 0x11])

        // RDATA: "ns1.example.com"
        data.append(contentsOf: [0x03])  // length 3
        data.append(contentsOf: "ns1".data(using: .ascii)!)
        data.append(contentsOf: [0x07])  // length 7
        data.append(contentsOf: "example".data(using: .ascii)!)
        data.append(contentsOf: [0x03])  // length 3
        data.append(contentsOf: "com".data(using: .ascii)!)
        data.append(contentsOf: [0x00])  // null terminator

        // Sentinel: to verify we didn't read past the record
        data.append(contentsOf: [0xDE, 0xAD])

        var buffer: any ByteBufferReading = ByteBufferReader(data)

        let record = try DNSRecordDecoder.decode(from: &buffer)

        // Verify record type
        #expect(record.recordType == .ns)

        // Verify it's an NS record
        let nsRecord = try #require(record as? NSRecord)

        #expect(
            nsRecord.payloadLabels.labels == ["ns1", "example", "com"],
            "NS record should have payload labels ['ns1', 'example', 'com'], got \(nsRecord.payloadLabels.labels)"
        )

        // Verify record name
        #expect(nsRecord.labels.labels == ["example", "com"])
    }

    @Test("decodes CNAME record with correct payload labels")
    func decodeCNAMERecord() throws {
        var data = Data()

        // Record name: "www.example.com"
        data.append(contentsOf: [0x03])
        data.append(contentsOf: "www".data(using: .ascii)!)
        data.append(contentsOf: [0x07])
        data.append(contentsOf: "example".data(using: .ascii)!)
        data.append(contentsOf: [0x03])
        data.append(contentsOf: "com".data(using: .ascii)!)
        data.append(contentsOf: [0x00])

        // Type: CNAME (5)
        data.append(contentsOf: [0x00, 0x05])

        // Class: IN (1)
        data.append(contentsOf: [0x00, 0x01])

        // TTL: 600
        data.append(contentsOf: [0x00, 0x00, 0x02, 0x58])

        // RDLENGTH: length of "example.com" = 13 bytes
        data.append(contentsOf: [0x00, 0x0D])

        // RDATA: "example.com" (the canonical name)
        data.append(contentsOf: [0x07])
        data.append(contentsOf: "example".data(using: .ascii)!)
        data.append(contentsOf: [0x03])
        data.append(contentsOf: "com".data(using: .ascii)!)
        data.append(contentsOf: [0x00])

        var buffer: any ByteBufferReading = ByteBufferReader(data)

        let record = try DNSRecordDecoder.decode(from: &buffer)

        #expect(record.recordType == .cname)

        let cnameRecord = try #require(record as? CNAMERecord)

        #expect(
            cnameRecord.payloadLabels.labels == ["example", "com"],
            "CNAME should point to ['example', 'com'], got \(cnameRecord.payloadLabels.labels)"
        )
    }

    @Test("decodes MX record with correct priority and payload labels")
    func decodeMXRecord() throws {
        var data = Data()

        // Record name: "example.com"
        data.append(contentsOf: [0x07])
        data.append(contentsOf: "example".data(using: .ascii)!)
        data.append(contentsOf: [0x03])
        data.append(contentsOf: "com".data(using: .ascii)!)
        data.append(contentsOf: [0x00])

        // Type: MX (15)
        data.append(contentsOf: [0x00, 0x0F])

        // Class: IN (1)
        data.append(contentsOf: [0x00, 0x01])

        // TTL: 3600
        data.append(contentsOf: [0x00, 0x00, 0x0E, 0x10])

        // RDLENGTH: 2 (priority) + 18 ("mail.example.com") = 20 bytes
        data.append(contentsOf: [0x00, 0x14])

        // RDATA:
        // Priority: 10
        data.append(contentsOf: [0x00, 0x0A])

        // Mail server: "mail.example.com"
        data.append(contentsOf: [0x04])
        data.append(contentsOf: "mail".data(using: .ascii)!)
        data.append(contentsOf: [0x07])
        data.append(contentsOf: "example".data(using: .ascii)!)
        data.append(contentsOf: [0x03])
        data.append(contentsOf: "com".data(using: .ascii)!)
        data.append(contentsOf: [0x00])

        var buffer: any ByteBufferReading = ByteBufferReader(data)

        let record = try DNSRecordDecoder.decode(from: &buffer)

        #expect(record.recordType == .mx)

        let mxRecord = try #require(record as? MXRecord)

        #expect(mxRecord.priority == 10, "MX priority should be 10, got \(mxRecord.priority)")
        #expect(
            mxRecord.payloadLabels.labels == ["mail", "example", "com"],
            "MX should have mail server ['mail', 'example', 'com'], got \(mxRecord.payloadLabels.labels)"
        )
    }

    @Test("decodes multiple records in sequence without buffer corruption")
    func decodeMultipleRecordsInSequence() throws {
        // This tests that decoding an NS record doesn't corrupt the buffer position
        // for subsequent records

        var data = Data()

        // First record: NS record for "example.com" -> "ns1.example.com"
        // Name
        data.append(contentsOf: [0x07])
        data.append(contentsOf: "example".data(using: .ascii)!)
        data.append(contentsOf: [0x03])
        data.append(contentsOf: "com".data(using: .ascii)!)
        data.append(contentsOf: [0x00])
        // Type NS, Class IN
        data.append(contentsOf: [0x00, 0x02, 0x00, 0x01])
        // TTL
        data.append(contentsOf: [0x00, 0x00, 0x01, 0x2C])
        // RDLENGTH: 17
        data.append(contentsOf: [0x00, 0x11])
        // RDATA: ns1.example.com
        data.append(contentsOf: [0x03])
        data.append(contentsOf: "ns1".data(using: .ascii)!)
        data.append(contentsOf: [0x07])
        data.append(contentsOf: "example".data(using: .ascii)!)
        data.append(contentsOf: [0x03])
        data.append(contentsOf: "com".data(using: .ascii)!)
        data.append(contentsOf: [0x00])

        // Second record: A record for "ns1.example.com" -> 192.168.1.1
        // Name
        data.append(contentsOf: [0x03])
        data.append(contentsOf: "ns1".data(using: .ascii)!)
        data.append(contentsOf: [0x07])
        data.append(contentsOf: "example".data(using: .ascii)!)
        data.append(contentsOf: [0x03])
        data.append(contentsOf: "com".data(using: .ascii)!)
        data.append(contentsOf: [0x00])
        // Type A, Class IN
        data.append(contentsOf: [0x00, 0x01, 0x00, 0x01])
        // TTL
        data.append(contentsOf: [0x00, 0x00, 0x01, 0x2C])
        // RDLENGTH: 4
        data.append(contentsOf: [0x00, 0x04])
        // RDATA: 192.168.1.1
        data.append(contentsOf: [192, 168, 1, 1])

        var buffer: any ByteBufferReading = ByteBufferReader(data)

        // Decode first record (NS)
        let record1 = try DNSRecordDecoder.decode(from: &buffer)
        let nsRecord = try #require(record1 as? NSRecord)
        #expect(nsRecord.payloadLabels.labels == ["ns1", "example", "com"])

        // Decode second record (A) - this would fail with buffer corruption bug
        let record2 = try DNSRecordDecoder.decode(from: &buffer)
        let aRecord = try #require(record2 as? ARecord)
        #expect(aRecord.labels.labels == ["ns1", "example", "com"])
        #expect(aRecord.address.fragments == [192, 168, 1, 1])
    }

    // MARK: - SOA Record Decoding

    @Test("decodes SOA record with all fields")
    func decodeSOARecord() throws {
        // This test verifies that SOA records correctly decode all fields:
        // - Primary name server (MNAME)
        // - Responsible mailbox (RNAME)
        // - Serial, Refresh, Retry, Expire, Minimum (5 x UInt32)
        //
        // Structure of an SOA record:
        // - Name: "example.com"
        // - Type: 6 (SOA)
        // - Class: 1 (IN)
        // - TTL: 3600
        // - RDLENGTH: calculated
        // - RDATA:
        //   - MNAME: "ns1.example.com"
        //   - RNAME: "admin.example.com"
        //   - SERIAL: 1 (0x00000001)
        //   - REFRESH: 2 (0x00000002)
        //   - RETRY: 3 (0x00000003)
        //   - EXPIRE: 4 (0x00000004)
        //   - MINIMUM: 5 (0x00000005)

        var data = Data()

        // Record name: "example.com"
        data.append(contentsOf: [0x07])  // length 7
        data.append(contentsOf: "example".data(using: .ascii)!)
        data.append(contentsOf: [0x03])  // length 3
        data.append(contentsOf: "com".data(using: .ascii)!)
        data.append(contentsOf: [0x00])  // null terminator

        // Type: SOA (6)
        data.append(contentsOf: [0x00, 0x06])

        // Class: IN (1)
        data.append(contentsOf: [0x00, 0x01])

        // TTL: 3600 (0x00000E10)
        data.append(contentsOf: [0x00, 0x00, 0x0E, 0x10])

        // RDLENGTH: We need to calculate this
        // MNAME: "ns1.example.com" = 1+3+1+7+1+3+1 = 17 bytes
        // RNAME: "admin.example.com" = 1+5+1+7+1+3+1 = 19 bytes
        // 5 x UInt32 = 20 bytes
        // Total: 17 + 19 + 20 = 56 bytes (0x0038)
        data.append(contentsOf: [0x00, 0x38])

        // RDATA:
        // MNAME: "ns1.example.com"
        data.append(contentsOf: [0x03])
        data.append(contentsOf: "ns1".data(using: .ascii)!)
        data.append(contentsOf: [0x07])
        data.append(contentsOf: "example".data(using: .ascii)!)
        data.append(contentsOf: [0x03])
        data.append(contentsOf: "com".data(using: .ascii)!)
        data.append(contentsOf: [0x00])

        // RNAME: "admin.example.com"
        data.append(contentsOf: [0x05])
        data.append(contentsOf: "admin".data(using: .ascii)!)
        data.append(contentsOf: [0x07])
        data.append(contentsOf: "example".data(using: .ascii)!)
        data.append(contentsOf: [0x03])
        data.append(contentsOf: "com".data(using: .ascii)!)
        data.append(contentsOf: [0x00])

        // SERIAL: 1 (0x00000001)
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x01])

        // REFRESH: 2 (0x00000002)
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x02])

        // RETRY: 3 (0x00000003)
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x03])

        // EXPIRE: 4 (0x00000004)
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x04])

        // MINIMUM: 5 (0x00000005)
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x05])

        var buffer: any ByteBufferReading = ByteBufferReader(data)

        let record = try DNSRecordDecoder.decode(from: &buffer)

        // Verify record type
        #expect(record.recordType == .soa)

        // Verify it's an SOA record
        let soaRecord = try #require(record as? SOARecord)

        // Verify record name
        #expect(soaRecord.labels.labels == ["example", "com"])

        // Verify primary name server
        #expect(
            soaRecord.primaryNameServer.labels == ["ns1", "example", "com"],
            "SOA primary name server should be ['ns1', 'example', 'com'], got \(soaRecord.primaryNameServer.labels)"
        )

        // Verify responsible mailbox
        #expect(
            soaRecord.responsibleMailbox.labels == ["admin", "example", "com"],
            "SOA responsible mailbox should be ['admin', 'example', 'com'], got \(soaRecord.responsibleMailbox.labels)"
        )

        // Verify numeric fields
        #expect(soaRecord.serial == 1, "Serial should be 1, got \(soaRecord.serial)")
        #expect(soaRecord.refresh == 2, "Refresh should be 2, got \(soaRecord.refresh)")
        #expect(soaRecord.retry == 3, "Retry should be 3, got \(soaRecord.retry)")
        #expect(soaRecord.expire == 4, "Expire should be 4, got \(soaRecord.expire)")
        #expect(soaRecord.minimum == 5, "Minimum should be 5, got \(soaRecord.minimum)")
    }

    @Test("encodes and decodes SOA record round-trip")
    func encodeDecodeSOARecordRoundTrip() throws {
        // Create an SOA record
        let originalRecord = SOARecord(
            labels: DNSLabels(labels: ["example", "com"]),
            recordType: .soa,
            recordClass: 1,
            timeToLive: 3600,
            primaryNameServer: DNSLabels(labels: ["ns1", "example", "com"]),
            responsibleMailbox: DNSLabels(labels: ["admin", "example", "com"]),
            serial: 2_024_010_101,
            refresh: 7200,
            retry: 3600,
            expire: 1_209_600,
            minimum: 86400
        )

        // Encode it
        var buffer: any ByteBufferWriting = ByteBufferWriter()
        try originalRecord.encode(into: &buffer)
        let encodedData = buffer.data

        // Decode it back
        var readBuffer: any ByteBufferReading = ByteBufferReader(encodedData)
        let decodedRecord = try DNSRecordDecoder.decode(from: &readBuffer)

        // Verify it's the same
        let soaRecord = try #require(decodedRecord as? SOARecord)

        #expect(soaRecord.labels.labels == originalRecord.labels.labels)
        #expect(soaRecord.recordType == originalRecord.recordType)
        #expect(soaRecord.recordClass == originalRecord.recordClass)
        #expect(soaRecord.timeToLive == originalRecord.timeToLive)
        #expect(soaRecord.primaryNameServer.labels == originalRecord.primaryNameServer.labels)
        #expect(soaRecord.responsibleMailbox.labels == originalRecord.responsibleMailbox.labels)
        #expect(soaRecord.serial == originalRecord.serial)
        #expect(soaRecord.refresh == originalRecord.refresh)
        #expect(soaRecord.retry == originalRecord.retry)
        #expect(soaRecord.expire == originalRecord.expire)
        #expect(soaRecord.minimum == originalRecord.minimum)
    }

    // MARK: - RDLENGTH Validation Tests

    @Test("throws error when A record has incorrect RDLENGTH")
    func aRecordInvalidRDLength() throws {
        var data = Data()

        // Record name: "example.com"
        data.append(contentsOf: [0x07])
        data.append(contentsOf: "example".data(using: .ascii)!)
        data.append(contentsOf: [0x03])
        data.append(contentsOf: "com".data(using: .ascii)!)
        data.append(contentsOf: [0x00])

        // Type: A (1)
        data.append(contentsOf: [0x00, 0x01])

        // Class: IN (1)
        data.append(contentsOf: [0x00, 0x01])

        // TTL: 300
        data.append(contentsOf: [0x00, 0x00, 0x01, 0x2C])

        // RDLENGTH: 5 (should be 4 for IPv4)
        data.append(contentsOf: [0x00, 0x05])

        // RDATA: 192.168.1.1 + extra byte
        data.append(contentsOf: [192, 168, 1, 1, 0])

        var buffer: any ByteBufferReading = ByteBufferReader(data)

        #expect(throws: DecoderError.self) {
            try DNSRecordDecoder.decode(from: &buffer)
        }
    }

    @Test("throws error when AAAA record has incorrect RDLENGTH")
    func aaaaRecordInvalidRDLength() throws {
        var data = Data()

        // Record name: "example.com"
        data.append(contentsOf: [0x07])
        data.append(contentsOf: "example".data(using: .ascii)!)
        data.append(contentsOf: [0x03])
        data.append(contentsOf: "com".data(using: .ascii)!)
        data.append(contentsOf: [0x00])

        // Type: AAAA (28)
        data.append(contentsOf: [0x00, 0x1C])

        // Class: IN (1)
        data.append(contentsOf: [0x00, 0x01])

        // TTL: 300
        data.append(contentsOf: [0x00, 0x00, 0x01, 0x2C])

        // RDLENGTH: 15 (should be 16 for IPv6)
        data.append(contentsOf: [0x00, 0x0F])

        // RDATA: 15 bytes (should be 16)
        data.append(
            contentsOf: [
                0x20, 0x01, 0x0d, 0xb8, 0x00, 0x00, 0x00, 0x00,
                0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            ]
        )

        var buffer: any ByteBufferReading = ByteBufferReader(data)

        #expect(throws: DecoderError.self) {
            try DNSRecordDecoder.decode(from: &buffer)
        }
    }

    @Test("throws error when SOA record has incorrect RDLENGTH")
    func soaRecordInvalidRDLength() throws {
        var data = Data()

        // Record name: "example.com"
        data.append(contentsOf: [0x07])
        data.append(contentsOf: "example".data(using: .ascii)!)
        data.append(contentsOf: [0x03])
        data.append(contentsOf: "com".data(using: .ascii)!)
        data.append(contentsOf: [0x00])

        // Type: SOA (6)
        data.append(contentsOf: [0x00, 0x06])

        // Class: IN (1)
        data.append(contentsOf: [0x00, 0x01])

        // TTL: 3600
        data.append(contentsOf: [0x00, 0x00, 0x0E, 0x10])

        // RDLENGTH: 50 (actual data is 56 bytes, so this should cause mismatch)
        data.append(contentsOf: [0x00, 0x32])

        // RDATA: (actual 56 bytes of data)
        // MNAME: "ns1.example.com" (17 bytes)
        data.append(contentsOf: [0x03])
        data.append(contentsOf: "ns1".data(using: .ascii)!)
        data.append(contentsOf: [0x07])
        data.append(contentsOf: "example".data(using: .ascii)!)
        data.append(contentsOf: [0x03])
        data.append(contentsOf: "com".data(using: .ascii)!)
        data.append(contentsOf: [0x00])

        // RNAME: "admin.example.com" (19 bytes)
        data.append(contentsOf: [0x05])
        data.append(contentsOf: "admin".data(using: .ascii)!)
        data.append(contentsOf: [0x07])
        data.append(contentsOf: "example".data(using: .ascii)!)
        data.append(contentsOf: [0x03])
        data.append(contentsOf: "com".data(using: .ascii)!)
        data.append(contentsOf: [0x00])

        // 5 x UInt32 (20 bytes)
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x01])  // SERIAL
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x02])  // REFRESH
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x03])  // RETRY
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x04])  // EXPIRE
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x05])  // MINIMUM

        var buffer: any ByteBufferReading = ByteBufferReader(data)

        #expect(throws: DecoderError.self) {
            try DNSRecordDecoder.decode(from: &buffer)
        }
    }

    // MARK: - Computed lengthOfCustomData

    @Test("SOA record computes lengthOfCustomData from its fields")
    func soaRecordComputesLength() {
        let record = SOARecord(
            labels: DNSLabels(labels: ["example", "com"]),
            recordType: .soa,
            recordClass: 1,
            timeToLive: 3600,
            primaryNameServer: DNSLabels(labels: ["ns1", "example", "com"]),
            responsibleMailbox: DNSLabels(labels: ["admin", "example", "com"]),
            serial: 1,
            refresh: 2,
            retry: 3,
            expire: 4,
            minimum: 5
        )

        // MNAME "ns1.example.com": (1+3) + (1+7) + (1+3) + 1 = 17
        // RNAME "admin.example.com": (1+5) + (1+7) + (1+3) + 1 = 19
        // 5 x UInt32 = 20
        // Total = 56
        #expect(record.lengthOfCustomData == 56)
    }

    @Test("NS record computes lengthOfCustomData from payload labels")
    func nsRecordComputesLength() {
        let record = NSRecord(
            labels: DNSLabels(labels: ["example", "com"]),
            recordType: .ns,
            recordClass: 1,
            timeToLive: 300,
            payloadLabels: DNSLabels(labels: ["ns1", "example", "com"])
        )

        // "ns1.example.com": (1+3) + (1+7) + (1+3) + 1 = 17
        #expect(record.lengthOfCustomData == 17)
    }

    @Test("CNAME record computes lengthOfCustomData from payload labels")
    func cnameRecordComputesLength() {
        let record = CNAMERecord(
            labels: DNSLabels(labels: ["www", "example", "com"]),
            recordType: .cname,
            recordClass: 1,
            timeToLive: 600,
            payloadLabels: DNSLabels(labels: ["example", "com"])
        )

        // "example.com": (1+7) + (1+3) + 1 = 13
        #expect(record.lengthOfCustomData == 13)
    }

    @Test("MX record computes lengthOfCustomData from priority and payload labels")
    func mxRecordComputesLength() {
        let record = MXRecord(
            labels: DNSLabels(labels: ["example", "com"]),
            recordType: .mx,
            recordClass: 1,
            timeToLive: 3600,
            priority: 10,
            payloadLabels: DNSLabels(labels: ["mail", "example", "com"])
        )

        // 2 (priority) + "mail.example.com": (1+4) + (1+7) + (1+3) + 1 = 2 + 18 = 20
        #expect(record.lengthOfCustomData == 20)
    }

    @Test("SOA record equality ignores wire format differences in lengthOfCustomData")
    func soaRecordEqualityAfterCompression() throws {
        // Build a packet with an SOA record whose MNAME and RNAME share a suffix
        let query = DNSQuery(labels: ["panhans", "dev"], recordType: .soa, recordClass: 1)
        let soaRecord = SOARecord(
            labels: DNSLabels(labels: ["panhans", "dev"]),
            recordType: .soa,
            recordClass: 1,
            timeToLive: 141,
            primaryNameServer: DNSLabels(labels: ["docks17", "rzone", "de"]),
            responsibleMailbox: DNSLabels(labels: ["hostmaster", "strato-rz", "de"]),
            serial: 2_023_062_341,
            refresh: 86400,
            retry: 7200,
            expire: 604_800,
            minimum: 300
        )

        let packet = try DNSPacket(
            id: 30738,
            isResponse: true,
            isRecursionDesired: true,
            isRecursionAvailable: true,
            queries: [query],
            records: [soaRecord]
        )

        // Encode with compression (which will compress ".de" suffix in RNAME)
        var encoder = DNSPacketEncoder()
        encoder.shouldCompressLabels = true
        let compressedData = try encoder.encode(packet: packet)

        // Decode the compressed packet
        let decoder = DNSPacketDecoder()
        let decodedPacket = try decoder.decode(from: compressedData)

        // Packets should be semantically equal
        #expect(decodedPacket == packet)

        // Verify the SOA records are equal
        let decodedSOA = try #require(decodedPacket.records.first as? SOARecord)
        #expect(decodedSOA == soaRecord)
    }

    @Test("SOA record round-trips through compressed encoding and decoding")
    func soaRecordCompressedRoundTrip() throws {
        let soaRecord = SOARecord(
            labels: DNSLabels(labels: ["example", "com"]),
            recordType: .soa,
            recordClass: 1,
            timeToLive: 3600,
            primaryNameServer: DNSLabels(labels: ["ns1", "example", "com"]),
            responsibleMailbox: DNSLabels(labels: ["admin", "example", "com"]),
            serial: 2_024_010_101,
            refresh: 7200,
            retry: 3600,
            expire: 1_209_600,
            minimum: 86400
        )

        let packet = try DNSPacket(
            id: 1234,
            isResponse: true,
            isRecursionDesired: true,
            queries: [DNSQuery(labels: ["example", "com"], recordType: .soa, recordClass: 1)],
            records: [soaRecord]
        )

        // Encode with compression
        var encoder = DNSPacketEncoder()
        encoder.shouldCompressLabels = true
        let compressedData = try encoder.encode(packet: packet)

        // Decode
        let decoder = DNSPacketDecoder()
        let decodedPacket = try decoder.decode(from: compressedData)

        // Re-encode
        let reEncodedData = try encoder.encode(packet: decodedPacket)

        // Should produce identical bytes (idempotent)
        #expect(compressedData == reEncodedData)

        // And decoded packets should be equal
        #expect(decodedPacket == packet)
    }

    @Test("SOA record encodes correct RDATA length with shared suffix compression")
    func soaRecordRDATALengthWithCompression() throws {
        // Create an SOA where MNAME and RNAME share the ".de" suffix
        let soaRecord = SOARecord(
            labels: DNSLabels(labels: ["test", "de"]),
            recordType: .soa,
            recordClass: 1,
            timeToLive: 300,
            primaryNameServer: DNSLabels(labels: ["ns1", "provider", "de"]),
            responsibleMailbox: DNSLabels(labels: ["admin", "provider", "de"]),
            serial: 1,
            refresh: 3600,
            retry: 900,
            expire: 86400,
            minimum: 300
        )

        let packet = try DNSPacket(
            id: 1,
            isResponse: true,
            isRecursionDesired: true,
            queries: [DNSQuery(labels: ["test", "de"], recordType: .soa, recordClass: 1)],
            records: [soaRecord]
        )

        // Encode with compression
        var encoder = DNSPacketEncoder()
        encoder.shouldCompressLabels = true
        let data = try encoder.encode(packet: packet)

        // Decode should succeed (RDATA length should match actual encoded data)
        let decoder = DNSPacketDecoder()
        let decoded = try decoder.decode(from: data)

        let decodedSOA = try #require(decoded.records.first as? SOARecord)
        #expect(decodedSOA.primaryNameServer.labels == ["ns1", "provider", "de"])
        #expect(decodedSOA.responsibleMailbox.labels == ["admin", "provider", "de"])
        #expect(decodedSOA.serial == 1)
    }

    @Test("decodes SOA record with compression pointers")
    func soaRecordWithCompression() throws {
        // This test verifies that SOA records correctly handle compression pointers
        // in both MNAME and RNAME fields.
        //
        // Packet structure:
        // 1. Query for "example.com" (so we can reference it later)
        // 2. SOA record where MNAME and RNAME use compression to reference "example.com"

        var data = Data()

        // Query section: "example.com" at offset 0
        data.append(contentsOf: [0x07])  // length 7
        data.append(contentsOf: "example".data(using: .ascii)!)
        data.append(contentsOf: [0x03])  // length 3
        data.append(contentsOf: "com".data(using: .ascii)!)
        data.append(contentsOf: [0x00])  // null terminator
        // Query type/class
        data.append(contentsOf: [0x00, 0x06, 0x00, 0x01])  // Type SOA, Class IN

        // SOA record starts here (offset 17)
        // Record name: pointer to offset 0 (0xC000 = compression pointer to "example.com")
        data.append(contentsOf: [0xC0, 0x00])

        // Type: SOA (6)
        data.append(contentsOf: [0x00, 0x06])

        // Class: IN (1)
        data.append(contentsOf: [0x00, 0x01])

        // TTL: 3600
        data.append(contentsOf: [0x00, 0x00, 0x0E, 0x10])

        // RDLENGTH: Calculate based on compressed data
        // MNAME: 0x03 "ns1" 0xC000 (pointer to "example.com") = 1+3+2 = 6 bytes
        // RNAME: 0x05 "admin" 0xC000 (pointer to "example.com") = 1+5+2 = 8 bytes
        // 5 x UInt32 = 20 bytes
        // Total: 6 + 8 + 20 = 34 bytes (0x0022)
        data.append(contentsOf: [0x00, 0x22])

        // RDATA:
        // MNAME: "ns1.example.com" using compression
        data.append(contentsOf: [0x03])  // length 3
        data.append(contentsOf: "ns1".data(using: .ascii)!)
        data.append(contentsOf: [0xC0, 0x00])  // pointer to "example.com" at offset 0

        // RNAME: "admin.example.com" using compression
        data.append(contentsOf: [0x05])  // length 5
        data.append(contentsOf: "admin".data(using: .ascii)!)
        data.append(contentsOf: [0xC0, 0x00])  // pointer to "example.com" at offset 0

        // SERIAL: 2024010101
        data.append(contentsOf: [0x78, 0xA3, 0xF1, 0x75])

        // REFRESH: 7200
        data.append(contentsOf: [0x00, 0x00, 0x1C, 0x20])

        // RETRY: 3600
        data.append(contentsOf: [0x00, 0x00, 0x0E, 0x10])

        // EXPIRE: 1209600
        data.append(contentsOf: [0x00, 0x12, 0x75, 0x00])

        // MINIMUM: 86400
        data.append(contentsOf: [0x00, 0x01, 0x51, 0x80])

        // Skip the query section (17 bytes) to get to the SOA record
        var buffer: any ByteBufferReading = ByteBufferReader(data)
        buffer.currentIndex = 17

        let record = try DNSRecordDecoder.decode(from: &buffer)

        // Verify record type
        #expect(record.recordType == .soa)

        // Verify it's an SOA record
        let soaRecord = try #require(record as? SOARecord)

        // Verify record name (should be "example.com" from compression)
        #expect(soaRecord.labels.labels == ["example", "com"])

        // Verify MNAME resolves correctly through compression
        #expect(
            soaRecord.primaryNameServer.labels == ["ns1", "example", "com"],
            "SOA MNAME should resolve to ['ns1', 'example', 'com'], got \(soaRecord.primaryNameServer.labels)"
        )

        // Verify RNAME resolves correctly through compression
        #expect(
            soaRecord.responsibleMailbox.labels == ["admin", "example", "com"],
            "SOA RNAME should resolve to ['admin', 'example', 'com'], got \(soaRecord.responsibleMailbox.labels)"
        )

        // Verify numeric fields
        #expect(soaRecord.serial == 2_024_010_101)
        #expect(soaRecord.refresh == 7200)
        #expect(soaRecord.retry == 3600)
        #expect(soaRecord.expire == 1_209_600)
        #expect(soaRecord.minimum == 86400)
    }

    // MARK: - PTR Record Tests

    @Test("decodes PTR record with correct domain name")
    func decodePTRRecord() throws {
        var data = Data()

        // Record name: "1.168.192.in-addr.arpa"
        data.append(contentsOf: [0x01])
        data.append(contentsOf: "1".data(using: .ascii)!)
        data.append(contentsOf: [0x03])
        data.append(contentsOf: "168".data(using: .ascii)!)
        data.append(contentsOf: [0x03])
        data.append(contentsOf: "192".data(using: .ascii)!)
        data.append(contentsOf: [0x07])
        data.append(contentsOf: "in-addr".data(using: .ascii)!)
        data.append(contentsOf: [0x04])
        data.append(contentsOf: "arpa".data(using: .ascii)!)
        data.append(contentsOf: [0x00])

        // Type: PTR (12)
        data.append(contentsOf: [0x00, 0x0C])

        // Class: IN (1)
        data.append(contentsOf: [0x00, 0x01])

        // TTL: 3600
        data.append(contentsOf: [0x00, 0x00, 0x0E, 0x10])

        // RDLENGTH: "host.example.com" = 1+4+1+7+1+3+1 = 18 bytes
        data.append(contentsOf: [0x00, 0x12])

        // RDATA: "host.example.com"
        data.append(contentsOf: [0x04])
        data.append(contentsOf: "host".data(using: .ascii)!)
        data.append(contentsOf: [0x07])
        data.append(contentsOf: "example".data(using: .ascii)!)
        data.append(contentsOf: [0x03])
        data.append(contentsOf: "com".data(using: .ascii)!)
        data.append(contentsOf: [0x00])

        var buffer: any ByteBufferReading = ByteBufferReader(data)

        let record = try DNSRecordDecoder.decode(from: &buffer)

        #expect(record.recordType == .ptr)

        let ptrRecord = try #require(record as? PTRRecord)

        #expect(ptrRecord.labels.labels == ["1", "168", "192", "in-addr", "arpa"])
        #expect(ptrRecord.domainName.labels == ["host", "example", "com"])
    }

    @Test("encodes and decodes PTR record round-trip")
    func encodeDecodePTRRecordRoundTrip() throws {
        let originalRecord = PTRRecord(
            labels: DNSLabels(labels: ["1", "168", "192", "in-addr", "arpa"]),
            recordType: .ptr,
            recordClass: 1,
            timeToLive: 3600,
            domainName: DNSLabels(labels: ["host", "example", "com"])
        )

        var buffer: any ByteBufferWriting = ByteBufferWriter()
        try originalRecord.encode(into: &buffer)
        let encodedData = buffer.data

        var readBuffer: any ByteBufferReading = ByteBufferReader(encodedData)
        let decodedRecord = try DNSRecordDecoder.decode(from: &readBuffer)

        let ptrRecord = try #require(decodedRecord as? PTRRecord)

        #expect(ptrRecord.labels.labels == originalRecord.labels.labels)
        #expect(ptrRecord.recordType == originalRecord.recordType)
        #expect(ptrRecord.recordClass == originalRecord.recordClass)
        #expect(ptrRecord.timeToLive == originalRecord.timeToLive)
        #expect(ptrRecord.domainName.labels == originalRecord.domainName.labels)
    }

    @Test("PTR record computes lengthOfCustomData from domain name")
    func ptrRecordComputesLength() {
        let record = PTRRecord(
            labels: DNSLabels(labels: ["1", "168", "192", "in-addr", "arpa"]),
            recordType: .ptr,
            recordClass: 1,
            timeToLive: 3600,
            domainName: DNSLabels(labels: ["host", "example", "com"])
        )

        // "host.example.com": (1+4) + (1+7) + (1+3) + 1 = 18
        #expect(record.lengthOfCustomData == 18)
    }

    @Test("PTR record round-trips through compressed encoding and decoding")
    func ptrRecordCompressedRoundTrip() throws {
        let ptrRecord = PTRRecord(
            labels: DNSLabels(labels: ["1", "168", "192", "in-addr", "arpa"]),
            recordType: .ptr,
            recordClass: 1,
            timeToLive: 3600,
            domainName: DNSLabels(labels: ["host", "example", "com"])
        )

        let packet = try DNSPacket(
            id: 5678,
            isResponse: true,
            isRecursionDesired: true,
            queries: [DNSQuery(labels: ["1", "168", "192", "in-addr", "arpa"], recordType: .ptr, recordClass: 1)],
            records: [ptrRecord]
        )

        var encoder = DNSPacketEncoder()
        encoder.shouldCompressLabels = true
        let compressedData = try encoder.encode(packet: packet)

        let decoder = DNSPacketDecoder()
        let decodedPacket = try decoder.decode(from: compressedData)

        #expect(decodedPacket == packet)
    }

    // MARK: - SRV Record Tests

    @Test("decodes SRV record with correct fields")
    func decodeSRVRecord() throws {
        var data = Data()

        // Record name: "_http._tcp.example.com"
        data.append(contentsOf: [0x05])
        data.append(contentsOf: "_http".data(using: .ascii)!)
        data.append(contentsOf: [0x04])
        data.append(contentsOf: "_tcp".data(using: .ascii)!)
        data.append(contentsOf: [0x07])
        data.append(contentsOf: "example".data(using: .ascii)!)
        data.append(contentsOf: [0x03])
        data.append(contentsOf: "com".data(using: .ascii)!)
        data.append(contentsOf: [0x00])

        // Type: SRV (33)
        data.append(contentsOf: [0x00, 0x21])

        // Class: IN (1)
        data.append(contentsOf: [0x00, 0x01])

        // TTL: 300
        data.append(contentsOf: [0x00, 0x00, 0x01, 0x2C])

        // RDLENGTH: 2+2+2 + "www.example.com" (1+3+1+7+1+3+1 = 17) = 23 bytes
        data.append(contentsOf: [0x00, 0x17])

        // RDATA:
        // Priority: 10
        data.append(contentsOf: [0x00, 0x0A])
        // Weight: 60
        data.append(contentsOf: [0x00, 0x3C])
        // Port: 80
        data.append(contentsOf: [0x00, 0x50])

        // Target: "www.example.com"
        data.append(contentsOf: [0x03])
        data.append(contentsOf: "www".data(using: .ascii)!)
        data.append(contentsOf: [0x07])
        data.append(contentsOf: "example".data(using: .ascii)!)
        data.append(contentsOf: [0x03])
        data.append(contentsOf: "com".data(using: .ascii)!)
        data.append(contentsOf: [0x00])

        var buffer: any ByteBufferReading = ByteBufferReader(data)

        let record = try DNSRecordDecoder.decode(from: &buffer)

        #expect(record.recordType == .srv)

        let srvRecord = try #require(record as? SRVRecord)

        #expect(srvRecord.labels.labels == ["_http", "_tcp", "example", "com"])
        #expect(srvRecord.priority == 10)
        #expect(srvRecord.weight == 60)
        #expect(srvRecord.port == 80)
        #expect(srvRecord.target.labels == ["www", "example", "com"])
    }

    @Test("encodes and decodes SRV record round-trip")
    func encodeDecodeSRVRecordRoundTrip() throws {
        let originalRecord = SRVRecord(
            labels: DNSLabels(labels: ["_http", "_tcp", "example", "com"]),
            recordType: .srv,
            recordClass: 1,
            timeToLive: 300,
            priority: 10,
            weight: 60,
            port: 80,
            target: DNSLabels(labels: ["www", "example", "com"])
        )

        var buffer: any ByteBufferWriting = ByteBufferWriter()
        try originalRecord.encode(into: &buffer)
        let encodedData = buffer.data

        var readBuffer: any ByteBufferReading = ByteBufferReader(encodedData)
        let decodedRecord = try DNSRecordDecoder.decode(from: &readBuffer)

        let srvRecord = try #require(decodedRecord as? SRVRecord)

        #expect(srvRecord.labels.labels == originalRecord.labels.labels)
        #expect(srvRecord.recordType == originalRecord.recordType)
        #expect(srvRecord.recordClass == originalRecord.recordClass)
        #expect(srvRecord.timeToLive == originalRecord.timeToLive)
        #expect(srvRecord.priority == originalRecord.priority)
        #expect(srvRecord.weight == originalRecord.weight)
        #expect(srvRecord.port == originalRecord.port)
        #expect(srvRecord.target.labels == originalRecord.target.labels)
    }

    @Test("SRV record computes lengthOfCustomData from fields")
    func srvRecordComputesLength() {
        let record = SRVRecord(
            labels: DNSLabels(labels: ["_http", "_tcp", "example", "com"]),
            recordType: .srv,
            recordClass: 1,
            timeToLive: 300,
            priority: 10,
            weight: 60,
            port: 80,
            target: DNSLabels(labels: ["www", "example", "com"])
        )

        // 6 (priority + weight + port) + "www.example.com": (1+3) + (1+7) + (1+3) + 1 = 6 + 17 = 23
        #expect(record.lengthOfCustomData == 23)
    }

    @Test("SRV record round-trips through compressed encoding and decoding")
    func srvRecordCompressedRoundTrip() throws {
        let srvRecord = SRVRecord(
            labels: DNSLabels(labels: ["_http", "_tcp", "example", "com"]),
            recordType: .srv,
            recordClass: 1,
            timeToLive: 300,
            priority: 10,
            weight: 60,
            port: 80,
            target: DNSLabels(labels: ["www", "example", "com"])
        )

        let packet = try DNSPacket(
            id: 9012,
            isResponse: true,
            isRecursionDesired: true,
            queries: [DNSQuery(labels: ["_http", "_tcp", "example", "com"], recordType: .srv, recordClass: 1)],
            records: [srvRecord]
        )

        var encoder = DNSPacketEncoder()
        encoder.shouldCompressLabels = true
        let compressedData = try encoder.encode(packet: packet)

        let decoder = DNSPacketDecoder()
        let decodedPacket = try decoder.decode(from: compressedData)

        #expect(decodedPacket == packet)
    }

}
