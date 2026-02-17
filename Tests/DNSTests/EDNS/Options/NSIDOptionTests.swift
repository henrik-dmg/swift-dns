//
//  NSIDOptionTests.swift
//  swift-dns
//

import DNS
import Foundation
import Testing

@Suite
struct NSIDOptionTests {

    @Test("code is nsid")
    func codeIsNSID() {
        #expect(makeOption().code == .nsid)
    }

    @Test("stores payload from initializer")
    func storesPayload() {
        let payload = Data([0x6E, 0x73, 0x31])
        let option = makeOption(payload: payload)
        #expect(option.payload == payload)
    }

    @Test("dataLength matches payload count")
    func dataLength() {
        let option = makeOption(payload: Data(repeating: 0, count: 10))
        #expect(option.dataLength == 10)
    }

    @Test("two options with same payload are equal")
    func equality() {
        #expect(makeOption() == makeOption())
    }

    @Test("two options with different payloads are not equal")
    func inequality() {
        let option1 = makeOption(payload: Data([1, 2, 3]))
        let option2 = makeOption(payload: Data([4, 5, 6]))
        #expect(option1 != option2)
    }

    // MARK: - Helpers

    private func makeOption(
        payload: Data = Data([0x6E, 0x73, 0x31])
    ) -> NSIDOption {
        NSIDOption(payload: payload)
    }

}
