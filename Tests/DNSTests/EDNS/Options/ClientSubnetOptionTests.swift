//
//  ClientSubnetOptionTests.swift
//  swift-dns
//

import DNS
import Foundation
import Testing

@Suite
struct ClientSubnetOptionTests {

    @Test("code is clientSubnet")
    func codeIsClientSubnet() {
        #expect(makeOption().code == .clientSubnet)
    }

    @Test("stores family from initializer")
    func storesFamily() {
        #expect(makeOption(family: 2).family == 2)
    }

    @Test("stores sourcePrefixLength from initializer")
    func storesSourcePrefixLength() {
        #expect(makeOption(sourcePrefixLength: 24).sourcePrefixLength == 24)
    }

    @Test("stores scopePrefixLength from initializer")
    func storesScopePrefixLength() {
        #expect(makeOption(scopePrefixLength: 16).scopePrefixLength == 16)
    }

    @Test("stores address from initializer")
    func storesAddress() {
        let addr = Data([192, 168, 1, 0])
        #expect(makeOption(address: addr).address == addr)
    }

    @Test("dataLength is 4 + address length")
    func dataLength() {
        let option = makeOption(address: Data([192, 168, 1, 0]))
        #expect(option.dataLength == 8)
    }

    @Test("two options with same values are equal")
    func equality() {
        #expect(makeOption() == makeOption())
    }

    @Test("two options with different family are not equal")
    func inequality() {
        let option1 = makeOption(family: 1)
        let option2 = makeOption(family: 2)
        #expect(option1 != option2)
    }

    // MARK: - Helpers

    private func makeOption(
        family: UInt16 = 1,
        sourcePrefixLength: UInt8 = 24,
        scopePrefixLength: UInt8 = 0,
        address: Data = Data([192, 168, 1])
    ) -> ClientSubnetOption {
        ClientSubnetOption(
            family: family,
            sourcePrefixLength: sourcePrefixLength,
            scopePrefixLength: scopePrefixLength,
            address: address
        )
    }

}
