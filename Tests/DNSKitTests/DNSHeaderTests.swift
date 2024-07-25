//
//  DNSHeaderTests.swift
//
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation
import Testing

@testable import DNSKit

@Suite
struct DNSHeaderTests {

    @Test
    func query() throws {
        let path = try #require(Bundle.module.url(forResource: "query_packet", withExtension: "txt"))
        let data = try Data(contentsOf: path)
        var byteBuffer = ByteBuffer(data.prefix(12))
        let header = try DNSHeader.decode(from: &byteBuffer)

        #expect(header.numberOfQueries == 1)
        #expect(header.numberOfRecords == 0)
        #expect(!header.isResponse)
    }

    @Test
    func response() throws {
        let path = try #require(Bundle.module.url(forResource: "response_packet", withExtension: "txt"))
        let data = try Data(contentsOf: path)
        var byteBuffer = ByteBuffer(data.prefix(12))
        let header = try DNSHeader.decode(from: &byteBuffer)

        #expect(header.numberOfQueries == 1)
        #expect(header.numberOfRecords == 1)
        #expect(header.isResponse)
    }

}
