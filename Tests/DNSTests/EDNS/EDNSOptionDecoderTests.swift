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

    // MARK: - Malformed Length Rejection

    @Test("rejects ClientSubnet option with dataLength less than 4")
    func rejectsClientSubnetTooShort() throws {
        var writer: ByteBufferWriting = ByteBufferWriter()
        writer.write(UInt16(EDNSOptionCode.clientSubnet.rawValue))  // code = 8
        writer.write(UInt16(3))  // dataLength = 3 (minimum is 4)
        writer.write(UInt8(0))
        writer.write(UInt8(1))
        writer.write(UInt8(24))  // 3 bytes of data

        var reader: ByteBufferReading = ByteBufferReader(writer.data)
        #expect {
            try EDNSOptionDecoder.decode(from: &reader)
        } throws: { error in
            guard let decoderError = error as? DecoderError else {
                return false
            }
            guard case .invalidEDNSOptionLength(let code, let length, let minimum) = decoderError else {
                return false
            }
            return code == .clientSubnet && length == 3 && minimum == 4
        }
    }

    @Test("rejects Cookie option with dataLength less than 8")
    func rejectsCookieTooShort() throws {
        var writer: ByteBufferWriting = ByteBufferWriter()
        writer.write(UInt16(EDNSOptionCode.cookie.rawValue))  // code = 10
        writer.write(UInt16(7))  // dataLength = 7 (minimum is 8)
        for _ in 0 ..< 7 {
            writer.write(UInt8(0xAB))
        }

        var reader: ByteBufferReading = ByteBufferReader(writer.data)
        #expect {
            try EDNSOptionDecoder.decode(from: &reader)
        } throws: { error in
            guard let decoderError = error as? DecoderError else {
                return false
            }
            guard case .invalidEDNSOptionLength(let code, let length, let minimum) = decoderError else {
                return false
            }
            return code == .cookie && length == 7 && minimum == 8
        }
    }

    @Test("rejects ExtendedDNSError option with dataLength less than 2")
    func rejectsExtendedDNSErrorTooShort() throws {
        var writer: ByteBufferWriting = ByteBufferWriter()
        writer.write(UInt16(EDNSOptionCode.extendedDNSError.rawValue))  // code = 15
        writer.write(UInt16(1))  // dataLength = 1 (minimum is 2)
        writer.write(UInt8(0x00))  // 1 byte of data

        var reader: ByteBufferReading = ByteBufferReader(writer.data)
        #expect {
            try EDNSOptionDecoder.decode(from: &reader)
        } throws: { error in
            guard let decoderError = error as? DecoderError else {
                return false
            }
            guard case .invalidEDNSOptionLength(let code, let length, let minimum) = decoderError else {
                return false
            }
            return code == .extendedDNSError && length == 1 && minimum == 2
        }
    }

}
