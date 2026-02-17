//
//  OPTRecordTests.swift
//  swift-dns
//

import Foundation
import Testing

@testable import DNS

@Suite
struct OPTRecordTests {

    @Test("default init sets udpPayloadSize to 4096")
    func defaultUDPPayloadSize() {
        let opt = OPTRecord()
        #expect(opt.udpPayloadSize == 4096)
    }

    @Test("default init sets extendedRCODE to 0")
    func defaultExtendedRCODE() {
        let opt = OPTRecord()
        #expect(opt.extendedRCODE == 0)
    }

    @Test("default init sets version to 0")
    func defaultVersion() {
        let opt = OPTRecord()
        #expect(opt.version == 0)
    }

    @Test("default init sets dnssecOK to false")
    func defaultDNSSECOK() {
        let opt = OPTRecord()
        #expect(opt.dnssecOK == false)
    }

    @Test("default init sets options to empty")
    func defaultOptions() {
        let opt = OPTRecord()
        #expect(opt.options.isEmpty)
    }

    @Test("stores udpPayloadSize from initializer")
    func storesUDPPayloadSize() {
        let opt = OPTRecord(udpPayloadSize: 1232)
        #expect(opt.udpPayloadSize == 1232)
    }

    @Test("stores extendedRCODE from initializer")
    func storesExtendedRCODE() {
        let opt = OPTRecord(extendedRCODE: 1)
        #expect(opt.extendedRCODE == 1)
    }

    @Test("stores version from initializer")
    func storesVersion() {
        let opt = OPTRecord(version: 1)
        #expect(opt.version == 1)
    }

    @Test("stores dnssecOK from initializer")
    func storesDNSSECOK() {
        let opt = OPTRecord(dnssecOK: true)
        #expect(opt.dnssecOK == true)
    }

    @Test("two OPT records with same values are equal")
    func equality() {
        let opt1 = OPTRecord(udpPayloadSize: 4096, extendedRCODE: 0, version: 0, dnssecOK: false)
        let opt2 = OPTRecord(udpPayloadSize: 4096, extendedRCODE: 0, version: 0, dnssecOK: false)
        #expect(opt1 == opt2)
    }

    @Test("two OPT records with different udpPayloadSize are not equal")
    func inequalityUDPSize() {
        let opt1 = OPTRecord(udpPayloadSize: 4096)
        let opt2 = OPTRecord(udpPayloadSize: 1232)
        #expect(opt1 != opt2)
    }

    @Test("two OPT records with different dnssecOK are not equal")
    func inequalityDNSSEC() {
        let opt1 = OPTRecord(dnssecOK: false)
        let opt2 = OPTRecord(dnssecOK: true)
        #expect(opt1 != opt2)
    }

    @Test("OPT records with same options are equal")
    func equalityWithOptions() {
        let options: [any EDNSOption] = [PaddingOption(length: 4)]
        let opt1 = OPTRecord(options: options)
        let opt2 = OPTRecord(options: options)
        #expect(opt1 == opt2)
    }

    @Test("OPT records with different options are not equal")
    func inequalityWithOptions() {
        let opt1 = OPTRecord(options: [PaddingOption(length: 4)])
        let opt2 = OPTRecord(options: [PaddingOption(length: 8)])
        #expect(opt1 != opt2)
    }

    @Test("encode and decode round-trip without options")
    func roundTripWithoutOptions() throws {
        let original = OPTRecord(udpPayloadSize: 1232, extendedRCODE: 0, version: 0, dnssecOK: true)

        var writer: ByteBufferWriting = ByteBufferWriter()
        try original.encode(into: &writer)

        var reader: ByteBufferReading = ByteBufferReader(writer.data)
        let decoded = try OPTRecord.decode(from: &reader)

        #expect(decoded == original)
    }

    @Test("encode and decode round-trip with cookie option")
    func roundTripWithCookie() throws {
        let cookie = CookieOption(clientCookie: Data(repeating: 0xAB, count: 8))
        let original = OPTRecord(udpPayloadSize: 4096, options: [cookie])

        var writer: ByteBufferWriting = ByteBufferWriter()
        try original.encode(into: &writer)

        var reader: ByteBufferReading = ByteBufferReader(writer.data)
        let decoded = try OPTRecord.decode(from: &reader)

        #expect(decoded == original)
    }

    @Test("encode and decode round-trip with multiple options")
    func roundTripWithMultipleOptions() throws {
        let cookie = CookieOption(
            clientCookie: Data(repeating: 0xAB, count: 8),
            serverCookie: Data(repeating: 0xCD, count: 16)
        )
        let padding = PaddingOption(length: 12)
        let original = OPTRecord(udpPayloadSize: 4096, dnssecOK: true, options: [cookie, padding])

        var writer: ByteBufferWriting = ByteBufferWriter()
        try original.encode(into: &writer)

        var reader: ByteBufferReading = ByteBufferReader(writer.data)
        let decoded = try OPTRecord.decode(from: &reader)

        #expect(decoded == original)
    }

    @Test("TTL field packing preserves extendedRCODE")
    func ttlPackingExtendedRCODE() throws {
        let original = OPTRecord(extendedRCODE: 3)

        var writer: ByteBufferWriting = ByteBufferWriter()
        try original.encode(into: &writer)

        var reader: ByteBufferReading = ByteBufferReader(writer.data)
        let decoded = try OPTRecord.decode(from: &reader)

        #expect(decoded.extendedRCODE == 3)
    }

    @Test("TTL field packing preserves DO flag")
    func ttlPackingDOFlag() throws {
        let original = OPTRecord(dnssecOK: true)

        var writer: ByteBufferWriting = ByteBufferWriter()
        try original.encode(into: &writer)

        var reader: ByteBufferReading = ByteBufferReader(writer.data)
        let decoded = try OPTRecord.decode(from: &reader)

        #expect(decoded.dnssecOK == true)
    }

    @Test("throws rdataLengthMismatch when options overshoot declared RDLENGTH")
    func rdataLengthMismatch() throws {
        // Build an OPT record with RDLENGTH = 7, but the single padding option
        // occupies 8 bytes (2 code + 2 length + 4 data). The options loop will
        // decode the option (consuming 8 bytes), leaving currentIndex one past
        // rdataEnd, which the guard should detect.
        var writer: ByteBufferWriting = ByteBufferWriter()
        writer.write(UInt8(0))  // NAME: root domain
        writer.write(UInt16(41))  // TYPE: OPT
        writer.write(UInt16(4096))  // CLASS: UDP payload size
        writer.write(UInt32(0))  // TTL: all zeros
        writer.write(UInt16(7))  // RDLENGTH: 7 (one less than the 8-byte option)
        writer.write(UInt16(EDNSOptionCode.padding.rawValue))  // option code = 12
        writer.write(UInt16(4))  // option dataLength = 4
        writer.write(UInt8(0))
        writer.write(UInt8(0))
        writer.write(UInt8(0))
        writer.write(UInt8(0))

        var reader: ByteBufferReading = ByteBufferReader(writer.data)
        #expect {
            try OPTRecord.decode(from: &reader)
        } throws: { error in
            guard let decoderError = error as? DecoderError else {
                return false
            }
            guard case .rdataLengthMismatch = decoderError else {
                return false
            }
            return true
        }
    }

    @Test("encode produces correct wire format for minimal OPT")
    func wireFormat() throws {
        let opt = OPTRecord(udpPayloadSize: 4096, extendedRCODE: 0, version: 0, dnssecOK: false)

        var writer: ByteBufferWriting = ByteBufferWriter()
        try opt.encode(into: &writer)

        let data = writer.data
        // NAME: 0x00 (root domain)
        #expect(data[0] == 0x00)
        // TYPE: 0x00 0x29 (41)
        #expect(data[1] == 0x00)
        #expect(data[2] == 0x29)
        // CLASS: 0x10 0x00 (4096)
        #expect(data[3] == 0x10)
        #expect(data[4] == 0x00)
        // TTL: 0x00 0x00 0x00 0x00 (all zeros)
        #expect(data[5] == 0x00)
        #expect(data[6] == 0x00)
        #expect(data[7] == 0x00)
        #expect(data[8] == 0x00)
        // RDLENGTH: 0x00 0x00 (no options)
        #expect(data[9] == 0x00)
        #expect(data[10] == 0x00)
    }

}
