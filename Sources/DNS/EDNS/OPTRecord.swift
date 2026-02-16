//
//  OPTRecord.swift
//  swift-dns
//

import Foundation

/// Represents an OPT pseudo-record used by EDNS (RFC 6891).
///
/// The OPT record is placed in the additional section of DNS messages to signal
/// extended capabilities. Unlike regular DNS records, it reinterprets the CLASS
/// and TTL fields:
/// - **CLASS** → ``udpPayloadSize`` (requestor's maximum UDP payload size)
/// - **TTL** → packed bitfield containing ``extendedRCODE``, ``version``, and ``dnssecOK``
///
/// The RDATA contains a sequence of EDNS ``EDNSOption`` values.
///
// Wire format:
// +------------+--------------+------------------------------+
// |  NAME (0)  |  TYPE (41)   |  CLASS (UDP payload size)    |
// +------------+--------------+------------------------------+
// |                 TTL (packed bitfield)                    |
// +------------------------------------------------------+
// |          RDLENGTH          |      RDATA (options)        |
// +----------------------------+-----------------------------+
public struct OPTRecord: Sendable {

    // MARK: - Properties

    /// The requestor's UDP payload size (repurposed CLASS field).
    public let udpPayloadSize: UInt16

    /// The upper 8 bits of the extended RCODE.
    public let extendedRCODE: UInt8

    /// The EDNS version (currently must be 0).
    public let version: UInt8

    /// The DNSSEC OK flag, indicating the requestor supports DNSSEC.
    public let dnssecOK: Bool

    /// The EDNS options carried in the RDATA.
    public let options: [any EDNSOption]

    // MARK: - Init

    /// Creates a new OPT record.
    ///
    /// - Parameters:
    ///   - udpPayloadSize: The requestor's maximum UDP payload size. Defaults to `4096`.
    ///   - extendedRCODE: The upper 8 bits of the extended RCODE. Defaults to `0`.
    ///   - version: The EDNS version. Defaults to `0`.
    ///   - dnssecOK: Whether DNSSEC is supported. Defaults to `false`.
    ///   - options: The EDNS options. Defaults to an empty array.
    public init(
        udpPayloadSize: UInt16 = 4096,
        extendedRCODE: UInt8 = 0,
        version: UInt8 = 0,
        dnssecOK: Bool = false,
        options: [any EDNSOption] = []
    ) {
        self.udpPayloadSize = udpPayloadSize
        self.extendedRCODE = extendedRCODE
        self.version = version
        self.dnssecOK = dnssecOK
        self.options = options
    }

}

// MARK: - Encoding

extension OPTRecord {

    /// Encodes the OPT record into the provided buffer.
    func encode(into buffer: inout ByteBufferWriting) throws {
        // NAME: root domain (single zero byte)
        buffer.write(UInt8(0))

        // TYPE: OPT (41)
        buffer.write(UInt16(41))

        // CLASS: UDP payload size
        buffer.write(udpPayloadSize)

        // TTL: packed bitfield
        let packedTTL =
            (UInt32(extendedRCODE) << 24)
            | (UInt32(version) << 16)
            | (dnssecOK ? 0x8000 : 0)
        buffer.write(packedTTL)

        // RDATA length placeholder
        let rdataLengthIndex = buffer.currentIndex
        buffer.write(UInt16(0))
        let rdataStart = buffer.currentIndex

        // Encode each EDNS option
        for option in options {
            try option.encode(into: &buffer)
        }

        // Write actual RDATA length
        let rdataLength = buffer.currentIndex - rdataStart
        buffer.write(UInt16(rdataLength), at: rdataLengthIndex)
    }

}

// MARK: - Decoding

extension OPTRecord {

    /// Decodes an OPT record from a byte buffer.
    ///
    /// - Parameter buffer: The buffer to read from.
    /// - Returns: A decoded ``OPTRecord``.
    /// - Throws: ``DecoderError`` if the data is malformed.
    static func decode(from buffer: inout ByteBufferReading) throws -> OPTRecord {
        // NAME: must be root domain (0x00)
        let name = try buffer.readByte()
        guard name == 0x00 else {
            throw DecoderError.invalidOPTRecordName
        }

        // TYPE: must be OPT (41)
        let recordType = try buffer.readUInt16()
        guard recordType == 41 else {
            throw DecoderError.cantReadRecordType(rawValue: recordType)
        }

        // CLASS: UDP payload size
        let udpPayloadSize = try buffer.readUInt16()

        // TTL: packed bitfield
        let packedTTL = try buffer.readUInt32()
        let extendedRCODE = UInt8((packedTTL >> 24) & 0xFF)
        let version = UInt8((packedTTL >> 16) & 0xFF)
        let dnssecOK = (packedTTL & 0x8000) != 0

        // RDATA length
        let rdataLength = Int(try buffer.readUInt16())
        let rdataEnd = buffer.currentIndex + rdataLength

        // Decode EDNS options from RDATA
        var options: [any EDNSOption] = []
        while buffer.currentIndex < rdataEnd {
            let option = try EDNSOptionDecoder.decode(from: &buffer)
            options.append(option)
        }

        return OPTRecord(
            udpPayloadSize: udpPayloadSize,
            extendedRCODE: extendedRCODE,
            version: version,
            dnssecOK: dnssecOK,
            options: options
        )
    }

}

// MARK: - Equatable

extension OPTRecord: Equatable {

    public static func == (lhs: OPTRecord, rhs: OPTRecord) -> Bool {
        let isMetadataEqual =
            lhs.udpPayloadSize == rhs.udpPayloadSize
            && lhs.extendedRCODE == rhs.extendedRCODE
            && lhs.version == rhs.version
            && lhs.dnssecOK == rhs.dnssecOK
            && lhs.options.count == rhs.options.count

        guard isMetadataEqual else {
            return false
        }

        for (index, option) in lhs.options.enumerated() {
            let otherOption = rhs.options[index]
            guard areOptionsEqual(lhs: option, rhs: otherOption) else {
                return false  // Early return on first mismatch
            }
        }

        return true
    }

    private static func areOptionsEqual(lhs: any EDNSOption, rhs: any EDNSOption) -> Bool {
        guard lhs.code == rhs.code else {
            return false
        }

        return switch lhs.code {
        case .nsid:
            areOptionsOfTypeEqual(lhs: lhs, rhs: rhs, type: NSIDOption.self)
        case .clientSubnet:
            areOptionsOfTypeEqual(lhs: lhs, rhs: rhs, type: ClientSubnetOption.self)
        case .cookie:
            areOptionsOfTypeEqual(lhs: lhs, rhs: rhs, type: CookieOption.self)
        case .padding:
            areOptionsOfTypeEqual(lhs: lhs, rhs: rhs, type: PaddingOption.self)
        case .extendedDNSError:
            areOptionsOfTypeEqual(lhs: lhs, rhs: rhs, type: ExtendedDNSErrorOption.self)
        case .unknown:
            areOptionsOfTypeEqual(lhs: lhs, rhs: rhs, type: UnknownEDNSOption.self)
        }
    }

    private static func areOptionsOfTypeEqual<Option: EDNSOption>(
        lhs: any EDNSOption,
        rhs: any EDNSOption,
        type: Option.Type
    ) -> Bool {
        guard let castedLHS = lhs as? Option, let castedRHS = rhs as? Option else {
            return false
        }
        return castedLHS == castedRHS
    }

}
