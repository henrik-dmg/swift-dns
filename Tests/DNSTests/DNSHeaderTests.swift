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
        let path = try #require(Bundle.module.url(forResource: "query-google.com-A", withExtension: nil))
        let data = try Data(contentsOf: path)
        var byteBuffer: any ByteBufferReading = ByteBufferReader(data.prefix(12))
        let header = try DNSHeader.decode(from: &byteBuffer)

        #expect(header.numberOfQueries == 1)
        #expect(header.numberOfRecords == 0)
        #expect(!header.isResponse)
    }

    @Test("decodes response")
    func response() throws {
        let path = try #require(Bundle.module.url(forResource: "response-google.com-A", withExtension: nil))
        let data = try Data(contentsOf: path)
        var byteBuffer: any ByteBufferReading = ByteBufferReader(data.prefix(12))
        let header = try DNSHeader.decode(from: &byteBuffer)

        #expect(header.numberOfQueries == 1)
        #expect(header.numberOfRecords == 1)
        #expect(header.isResponse)
    }

}
