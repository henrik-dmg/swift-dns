//
//  Data+ExtensionsTests.swift
//  swift-dns
//
//  Created by Henrik Panhans on 20.04.25.
//

import Foundation
import Testing

@testable import DNS

@Suite
struct DataExtensionTests {

    @Test
    func hexadecimalDescription() {
        let data = Data([0xF1, 0x02, 0xC3, 0xA4])
        #expect(data.hexEncodedString() == "f1 02 c3 a4")
    }

    @Test
    func hexadecimalDescriptionUppercase() {
        let data = Data([0xF1, 0x02, 0xC3, 0xA4])
        #expect(data.hexEncodedString(options: .upperCase) == "F1 02 C3 A4")
    }

}
