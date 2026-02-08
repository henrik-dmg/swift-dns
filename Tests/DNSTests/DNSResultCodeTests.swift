//
//  DNSResultCodeTests.swift
//  swift-dns
//
//  Created by Henrik Panhans on 20.04.25.
//

import Foundation
import Testing

@testable import DNS

@Suite
struct DNSResultCodeTests {

    @Test("codes match names", arguments: 0 ... 10)  // We could go all the way to UInt8.max here but that's overkill
    func codeNames(value: UInt8) throws {
        let resultCode = try #require(DNSResultCode(rawValue: value))
        switch value {
        case 0: #expect(resultCode == .noError)
        case 1: #expect(resultCode == .formatError)
        case 2: #expect(resultCode == .serverFailure)
        case 3: #expect(resultCode == .nonExistentDomain)
        case 4: #expect(resultCode == .notImplemented)
        case 5: #expect(resultCode == .queryRefused)
        default:
            #expect(resultCode == .other(value))
        }
        #expect(resultCode.rawValue == value)
    }

}
