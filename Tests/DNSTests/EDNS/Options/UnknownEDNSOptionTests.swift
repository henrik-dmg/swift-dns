//
//  UnknownEDNSOptionTests.swift
//  swift-dns
//

import DNS
import Foundation
import Testing

@Suite
struct UnknownEDNSOptionTests {

    @Test("stores code from initializer")
    func storesCode() {
        let option = makeOption(code: .unknown(99))
        #expect(option.code == .unknown(99))
    }

    @Test("stores data from initializer")
    func storesData() {
        let data = Data([1, 2, 3])
        let option = makeOption(data: data)
        #expect(option.data == data)
    }

    @Test("dataLength matches data count")
    func dataLength() {
        let option = makeOption(data: Data([1, 2, 3, 4, 5]))
        #expect(option.dataLength == 5)
    }

    @Test("two options with same values are equal")
    func equality() {
        #expect(makeOption() == makeOption())
    }

    @Test("two options with different data are not equal")
    func inequality() {
        let option1 = makeOption(data: Data([1, 2, 3]))
        let option2 = makeOption(data: Data([4, 5, 6]))
        #expect(option1 != option2)
    }

    // MARK: - Helpers

    private func makeOption(
        code: EDNSOptionCode = .unknown(99),
        data: Data = Data([0xDE, 0xAD])
    ) -> UnknownEDNSOption {
        UnknownEDNSOption(code: code, data: data)
    }

}
