//
//  DNSOperationCodeTests.swift
//  swift-dns
//
//  Created by Henrik Panhans on 20.04.25.
//

import Foundation
import Testing

@testable import DNS

@Suite
struct DNSOperationCodeTests {

    @Test("codes match names", arguments: 0 ... 10)  // We could go all the way to UInt8.max here but that's overkill
    func codeNames(value: UInt8) throws {
        let resultCode = try #require(DNSOperationCode(rawValue: value))
        switch value {
        case 0: #expect(resultCode == .query)
        case 1: #expect(resultCode == .inverseQuery)
        case 2: #expect(resultCode == .status)
        default:
            #expect(resultCode == .other(value))
        }
        #expect(resultCode.rawValue == value)
    }

}
