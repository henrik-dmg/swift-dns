//
//  EDNSOptionDecoderTests.swift
//  swift-dns
//

import Foundation
import Testing

@testable import DNS

@Suite
struct EDNSOptionDecoderTests {

    @Test("decodes NSID option")
    func decodesNSID() throws {
        let original = NSIDOption(payload: Data([0x6E, 0x73, 0x31]))

        var writer: ByteBufferWriting = ByteBufferWriter()
        try original.encode(into: &writer)

        var reader: ByteBufferReading = ByteBufferReader(writer.data)
        let decoded = try EDNSOptionDecoder.decode(from: &reader)

        #expect(decoded.code == .nsid)
        #expect(decoded as? NSIDOption == original)
    }

    @Test("decodes ClientSubnet option")
    func decodesClientSubnet() throws {
        let original = ClientSubnetOption(
            family: 1,
            sourcePrefixLength: 24,
            scopePrefixLength: 0,
            address: Data([192, 168, 1])
        )

        var writer: ByteBufferWriting = ByteBufferWriter()
        try original.encode(into: &writer)

        var reader: ByteBufferReading = ByteBufferReader(writer.data)
        let decoded = try EDNSOptionDecoder.decode(from: &reader)

        #expect(decoded.code == .clientSubnet)
        #expect(decoded as? ClientSubnetOption == original)
    }

    @Test("decodes Cookie option without server cookie")
    func decodesCookieWithoutServer() throws {
        let original = CookieOption(clientCookie: Data(repeating: 0xAB, count: 8))

        var writer: ByteBufferWriting = ByteBufferWriter()
        try original.encode(into: &writer)

        var reader: ByteBufferReading = ByteBufferReader(writer.data)
        let decoded = try EDNSOptionDecoder.decode(from: &reader)

        #expect(decoded.code == .cookie)
        #expect(decoded as? CookieOption == original)
    }

    @Test("decodes Cookie option with server cookie")
    func decodesCookieWithServer() throws {
        let original = CookieOption(
            clientCookie: Data(repeating: 0xAB, count: 8),
            serverCookie: Data(repeating: 0xCD, count: 16)
        )

        var writer: ByteBufferWriting = ByteBufferWriter()
        try original.encode(into: &writer)

        var reader: ByteBufferReading = ByteBufferReader(writer.data)
        let decoded = try EDNSOptionDecoder.decode(from: &reader)

        #expect(decoded.code == .cookie)
        #expect(decoded as? CookieOption == original)
    }

    @Test("decodes Padding option")
    func decodesPadding() throws {
        let original = PaddingOption(length: 8)

        var writer: ByteBufferWriting = ByteBufferWriter()
        try original.encode(into: &writer)

        var reader: ByteBufferReading = ByteBufferReader(writer.data)
        let decoded = try EDNSOptionDecoder.decode(from: &reader)

        #expect(decoded.code == .padding)
        #expect(decoded as? PaddingOption == original)
    }

    @Test("decodes ExtendedDNSError option without extra text")
    func decodesExtendedDNSErrorWithoutText() throws {
        let original = ExtendedDNSErrorOption(infoCode: 6)

        var writer: ByteBufferWriting = ByteBufferWriter()
        try original.encode(into: &writer)

        var reader: ByteBufferReading = ByteBufferReader(writer.data)
        let decoded = try EDNSOptionDecoder.decode(from: &reader)

        #expect(decoded.code == .extendedDNSError)
        #expect(decoded as? ExtendedDNSErrorOption == original)
    }

    @Test("decodes ExtendedDNSError option with extra text")
    func decodesExtendedDNSErrorWithText() throws {
        let original = ExtendedDNSErrorOption(infoCode: 6, extraText: "DNSSEC bogus")

        var writer: ByteBufferWriting = ByteBufferWriter()
        try original.encode(into: &writer)

        var reader: ByteBufferReading = ByteBufferReader(writer.data)
        let decoded = try EDNSOptionDecoder.decode(from: &reader)

        #expect(decoded.code == .extendedDNSError)
        #expect(decoded as? ExtendedDNSErrorOption == original)
    }

    @Test("decodes unknown option code as UnknownEDNSOption")
    func decodesUnknown() throws {
        let original = UnknownEDNSOption(code: .unknown(42), data: Data([1, 2, 3]))

        var writer: ByteBufferWriting = ByteBufferWriter()
        try original.encode(into: &writer)

        var reader: ByteBufferReading = ByteBufferReader(writer.data)
        let decoded = try EDNSOptionDecoder.decode(from: &reader)

        #expect(decoded.code == .unknown(42))
        #expect(decoded as? UnknownEDNSOption == original)
    }

}
