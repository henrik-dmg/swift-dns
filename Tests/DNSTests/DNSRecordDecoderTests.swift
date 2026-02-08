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

    // MARK: - Bug 1: NS/CNAME/MX Record Decoding Tests

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

        // BUG CHECK: The payload labels should be "ns1.example.com"
        // With the bug, the decoder would read from the wrong position
        #expect(
            nsRecord.paylodLabels.labels == ["ns1", "example", "com"],
            "NS record should have payload labels ['ns1', 'example', 'com'], got \(nsRecord.paylodLabels.labels)"
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

        // BUG CHECK: Payload should be the canonical name
        #expect(
            cnameRecord.paylodLabels.labels == ["example", "com"],
            "CNAME should point to ['example', 'com'], got \(cnameRecord.paylodLabels.labels)"
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

        // BUG CHECK: Priority and mail server should be correctly decoded
        #expect(mxRecord.priority == 10, "MX priority should be 10, got \(mxRecord.priority)")
        #expect(
            mxRecord.paylodLabels.labels == ["mail", "example", "com"],
            "MX should have mail server ['mail', 'example', 'com'], got \(mxRecord.paylodLabels.labels)"
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
        #expect(nsRecord.paylodLabels.labels == ["ns1", "example", "com"])

        // Decode second record (A) - this would fail with buffer corruption bug
        let record2 = try DNSRecordDecoder.decode(from: &buffer)
        let aRecord = try #require(record2 as? ARecord)
        #expect(aRecord.labels.labels == ["ns1", "example", "com"])
        #expect(aRecord.address.fragments == [192, 168, 1, 1])
    }

}
