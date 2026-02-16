//
//  EDNSOptionCodeTests.swift
//  swift-dns
//

import DNS
import Testing

@Suite
struct EDNSOptionCodeTests {

    @Test("nsid has raw value 3")
    func nsidRawValue() {
        #expect(EDNSOptionCode.nsid.rawValue == 3)
    }

    @Test("clientSubnet has raw value 8")
    func clientSubnetRawValue() {
        #expect(EDNSOptionCode.clientSubnet.rawValue == 8)
    }

    @Test("cookie has raw value 10")
    func cookieRawValue() {
        #expect(EDNSOptionCode.cookie.rawValue == 10)
    }

    @Test("padding has raw value 12")
    func paddingRawValue() {
        #expect(EDNSOptionCode.padding.rawValue == 12)
    }

    @Test("extendedDNSError has raw value 15")
    func extendedDNSErrorRawValue() {
        #expect(EDNSOptionCode.extendedDNSError.rawValue == 15)
    }

    @Test("unknown preserves raw value")
    func unknownRawValue() {
        #expect(EDNSOptionCode.unknown(99).rawValue == 99)
    }

    @Test("init from raw value 3 returns nsid")
    func initFromNSID() {
        #expect(EDNSOptionCode(rawValue: 3) == .nsid)
    }

    @Test("init from raw value 8 returns clientSubnet")
    func initFromClientSubnet() {
        #expect(EDNSOptionCode(rawValue: 8) == .clientSubnet)
    }

    @Test("init from raw value 10 returns cookie")
    func initFromCookie() {
        #expect(EDNSOptionCode(rawValue: 10) == .cookie)
    }

    @Test("init from raw value 12 returns padding")
    func initFromPadding() {
        #expect(EDNSOptionCode(rawValue: 12) == .padding)
    }

    @Test("init from raw value 15 returns extendedDNSError")
    func initFromExtendedDNSError() {
        #expect(EDNSOptionCode(rawValue: 15) == .extendedDNSError)
    }

    @Test("init from unrecognized raw value returns unknown")
    func initFromUnknown() {
        let code = EDNSOptionCode(rawValue: 42)
        #expect(code == .unknown(42))
    }

    @Test("two equal codes are equal")
    func equality() {
        #expect(EDNSOptionCode.nsid == EDNSOptionCode.nsid)
    }

    @Test("two different codes are not equal")
    func inequality() {
        #expect(EDNSOptionCode.nsid != EDNSOptionCode.cookie)
    }

}
