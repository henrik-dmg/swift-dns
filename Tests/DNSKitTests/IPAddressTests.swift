//
//  IPAddressTests.swift
//  swift-dns
//
//  Created by Henrik Panhans on 26.07.24.
//

import Testing

@testable import DNSKit

@Suite
struct IPAddressTests {

    @Test func ipv4() async throws {
        let address = IPv4Address(192, 178, 168, 9)
        #expect(address.formattedAddress() == "192.178.168.9")
    }

    @Test func ipv6LongFormat() async throws {
        let address = IPv6Address(1, 1, 1, 1, 1, 1, 1, 1)
        let expectedString = Array(repeating: "01", count: 8).joined(separator: ":")
        #expect(address.formattedAddress() == expectedString)
    }

    @Test func ipv6ShortFormat() async throws {
        // Example address from Wikipedia: https://en.wikipedia.org/wiki/IPv6
        let address = IPv6Address(8193, 3512, 0, 0, 0, 35374, 880, 29492)
        #expect(address.formattedAddress().lowercased() == "2001:db8::8a2e:370:7334")
    }

}
