//
//  DNSRecordTypeTests.swift
//  swift-dns
//
//  Created by Henrik Panhans on 26.07.24.
//

import Foundation
import Testing

@testable import DNSKit

@Suite
struct DNSRecordTypeTests {

    @Test("codes match type names", arguments: DNSRecordType.allCases)
    func recordTypeEncodesAndDecodesTheSameValue(recordType: DNSRecordType) throws {
        var writer: any ByteBufferWriting = ByteBufferWriter()
        try recordType.encode(into: &writer)

        var reader: any ByteBufferReading = ByteBufferReader(writer.data)
        let decodedRecordType = try DNSRecordType.decode(from: &reader)

        #expect(decodedRecordType == recordType)
    }

}
