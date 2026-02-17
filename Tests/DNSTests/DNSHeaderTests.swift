//
//  DNSHeaderTests.swift
//
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation
import Testing

@testable import DNS

@Suite
struct DNSHeaderTests {

    @Test("decodes query")
    func query() throws {
        let path = try #require(Bundle.module.url(forResource: "query-noedns-google.com-A", withExtension: nil))
        let data = try Data(contentsOf: path)
        var byteBuffer: any ByteBufferReading = ByteBufferReader(data.prefix(12))
        let header = try DNSHeader.decode(from: &byteBuffer)

        #expect(header.numberOfQueries == 1)
        #expect(header.numberOfRecords == 0)
        #expect(!header.isResponse)
    }

    @Test("decodes response")
    func response() throws {
        let path = try #require(Bundle.module.url(forResource: "response-noedns-google.com-A", withExtension: nil))
        let data = try Data(contentsOf: path)
        var byteBuffer: any ByteBufferReading = ByteBufferReader(data.prefix(12))
        let header = try DNSHeader.decode(from: &byteBuffer)

        #expect(header.numberOfQueries == 1)
        #expect(header.numberOfRecords == 1)
        #expect(header.isResponse)
    }

    // MARK: - EDNS Result Code Encoding

    @Test("encoding badVersion does not corrupt CD/AD/Z/RA bits")
    func badVersionDoesNotCorruptFlags() throws {
        let header = DNSHeader(
            id: 0,
            isRecursionDesired: false,
            isMessageTruncated: false,
            isAnswerAuthoritative: false,
            isCheckingDisabled: false,
            isAuthenticatedData: false,
            isRecursionAvailable: false,
            isResponse: false,
            operationCode: .query,
            resultCode: .badVersion,
            z: false,
            numberOfQueries: 0,
            numberOfRecords: 0,
            numberOfAuthorities: 0,
            numberOfResources: 0
        )

        var writer: ByteBufferWriting = ByteBufferWriter()
        try header.encode(into: &writer)

        // flagB is byte index 3 (after 2-byte ID and 1-byte flagA)
        let flagB = writer.data[3]
        #expect(flagB & 0x0F == 0)  // RCODE nibble = 0 (rawValue 16 masked to 4 bits)
        #expect(flagB & 0xF0 == 0)  // CD/AD/Z/RA bits all clear
    }

    @Test("encoding badCookie writes RCODE nibble 7 without corrupting upper bits")
    func badCookieDoesNotCorruptFlags() throws {
        let header = DNSHeader(
            id: 0,
            isRecursionDesired: false,
            isMessageTruncated: false,
            isAnswerAuthoritative: false,
            isCheckingDisabled: false,
            isAuthenticatedData: false,
            isRecursionAvailable: false,
            isResponse: false,
            operationCode: .query,
            resultCode: .badCookie,
            z: false,
            numberOfQueries: 0,
            numberOfRecords: 0,
            numberOfAuthorities: 0,
            numberOfResources: 0
        )

        var writer: ByteBufferWriting = ByteBufferWriter()
        try header.encode(into: &writer)

        // flagB is byte index 3
        let flagB = writer.data[3]
        #expect(flagB & 0x0F == 7)  // RCODE nibble = 7 (rawValue 23 & 0x0F)
        #expect(flagB & 0xF0 == 0)  // CD/AD/Z/RA bits all clear
    }

}
