//
//  CookieOptionTests.swift
//  swift-dns
//

import DNS
import Foundation
import Testing

@Suite
struct CookieOptionTests {

    @Test("code is cookie")
    func codeIsCookie() {
        #expect(makeOption().code == .cookie)
    }

    @Test("stores clientCookie from initializer")
    func storesClientCookie() {
        let cookie = Data(repeating: 0xAA, count: 8)
        #expect(makeOption(clientCookie: cookie).clientCookie == cookie)
    }

    @Test("stores serverCookie from initializer")
    func storesServerCookie() {
        let serverCookie = Data(repeating: 0xBB, count: 16)
        let option = makeOption(serverCookie: serverCookie)
        #expect(option.serverCookie == serverCookie)
    }

    @Test("serverCookie defaults to nil")
    func serverCookieDefaultsToNil() {
        let option = CookieOption(clientCookie: Data(repeating: 0, count: 8))
        #expect(option.serverCookie == nil)
    }

    @Test("dataLength is 8 when no server cookie")
    func dataLengthWithoutServerCookie() {
        let option = CookieOption(clientCookie: Data(repeating: 0, count: 8))
        #expect(option.dataLength == 8)
    }

    @Test("dataLength includes server cookie length")
    func dataLengthWithServerCookie() {
        let option = makeOption(serverCookie: Data(repeating: 0xBB, count: 16))
        #expect(option.dataLength == 24)
    }

    @Test("two options with same values are equal")
    func equality() {
        #expect(makeOption() == makeOption())
    }

    @Test("two options with different client cookies are not equal")
    func inequality() {
        let option1 = makeOption(clientCookie: Data(repeating: 0xAA, count: 8))
        let option2 = makeOption(clientCookie: Data(repeating: 0xBB, count: 8))
        #expect(option1 != option2)
    }

    // MARK: - Helpers

    private func makeOption(
        clientCookie: Data = Data(repeating: 0xAB, count: 8),
        serverCookie: Data? = Data(repeating: 0xCD, count: 8)
    ) -> CookieOption {
        CookieOption(clientCookie: clientCookie, serverCookie: serverCookie)
    }

}
