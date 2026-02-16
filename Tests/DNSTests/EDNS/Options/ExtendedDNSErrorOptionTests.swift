//
//  ExtendedDNSErrorOptionTests.swift
//  swift-dns
//

import DNS
import Foundation
import Testing

@Suite
struct ExtendedDNSErrorOptionTests {

    @Test("code is extendedDNSError")
    func codeIsExtendedDNSError() {
        #expect(makeOption().code == .extendedDNSError)
    }

    @Test("stores infoCode from initializer")
    func storesInfoCode() {
        #expect(makeOption(infoCode: 6).infoCode == 6)
    }

    @Test("stores extraText from initializer")
    func storesExtraText() {
        #expect(makeOption(extraText: "DNSSEC bogus").extraText == "DNSSEC bogus")
    }

    @Test("extraText defaults to nil")
    func extraTextDefaultsToNil() {
        let option = ExtendedDNSErrorOption(infoCode: 0)
        #expect(option.extraText == nil)
    }

    @Test("dataLength is 2 when no extra text")
    func dataLengthWithoutExtraText() {
        let option = ExtendedDNSErrorOption(infoCode: 0)
        #expect(option.dataLength == 2)
    }

    @Test("dataLength includes extra text UTF-8 length")
    func dataLengthWithExtraText() {
        let option = makeOption(extraText: "test")
        #expect(option.dataLength == 6)  // 2 + 4
    }

    @Test("two options with same values are equal")
    func equality() {
        #expect(makeOption() == makeOption())
    }

    @Test("two options with different info codes are not equal")
    func inequality() {
        let option1 = makeOption(infoCode: 1)
        let option2 = makeOption(infoCode: 2)
        #expect(option1 != option2)
    }

    // MARK: - Helpers

    private func makeOption(
        infoCode: UInt16 = 6,
        extraText: String? = "DNSSEC bogus"
    ) -> ExtendedDNSErrorOption {
        ExtendedDNSErrorOption(infoCode: infoCode, extraText: extraText)
    }

}
