//
//  DNSHeaderTests.swift
//  
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation
import Testing

@Suite
struct DNSHeaderTests {

    @Test
    func helloWorld() throws {
        let path = try #require(Bundle.module.url(forResource: "query_packet", withExtension: "txt"))
        let data = try Data(contentsOf: path)
        print(data.hexEncodedString())
    }

}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined(separator: " ")
    }
}
