//
//  DNSHeader.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

public struct DNSHeader: Equatable, Sendable {

    public var id: UInt16
    public var isRecursionDesired: Bool
    public var isMessageTruncated: Bool
    public var isAnswerAuthorative: Bool
    public var opCode: UInt8
    public var isResponse: Bool

    public var resultCode: DNSResultCode
    public var isCheckingDisabled: Bool
    public var isAuthedData: Bool
    public var z: Bool  // I dont know what this is
    public var isRecursionAvailable: Bool

    public var numberOfQueries: UInt16
    public var numberOfRecords: UInt16
    public var numberOfAuthorities: UInt16
    public var numberOfResources: UInt16

}

// MARK: - Decoding

extension DNSHeader: DNSPacketDecodable {

    //  | RFC Name | Descriptive Name     | Length             |
    //  | -------- | -------------------- | ------------------ |
    //  | ID       | Packet Identifier    | 16 bits            |
    //  | QR       | Query Response       | 1 bit              |
    //  | OPCODE   | Operation Code       | 4 bits             |
    //  | AA       | Authoritative Answer | 1 bit              |
    //  | TC       | Truncated Message    | 1 bit              |
    //  | RD       | Recursion Desired    | 1 bit              |
    //  | RA       | Recursion Available  | 1 bit              |
    //  | Z        | Reserved             | 3 bits             |
    //  | RCODE    | Response Code        | 4 bits             |
    //  | QDCOUNT  | Question Count       | 16 bits            |
    //  | ANCOUNT  | Answer Count         | 16 bits            |
    //  | NSCOUNT  | Authority Count      | 16 bits            |
    //  | ARCOUNT  | Additional Count     | 16 bits            |
    static func decode(from buffer: inout ByteBufferReading) throws -> DNSHeader {
        let id = try buffer.readUInt16()

        let flagsA = try buffer.readByte()
        let isRecursionDesired = (flagsA & (1 << 0)) > 0
        let isMessageTruncated = (flagsA & (1 << 1)) > 0
        let isAnswerAuthorative = (flagsA & (1 << 2)) > 0
        let opCode = (flagsA >> 3) & 0x0F
        let isResponse = (flagsA & (1 << 7)) > 0

        let flagsB = try buffer.readByte()
        let resultCode = DNSResultCode(rawValue: flagsB & 0x0F)
        let isCheckingDisabled = (flagsB & (1 << 4)) > 0
        let isAuthedData = (flagsB & (1 << 5)) > 0
        let z = (flagsB & (1 << 6)) > 0
        let isRecursionAvailable = (flagsB & (1 << 7)) > 0

        let numberOfQueries = try buffer.readUInt16()
        let numberOfRecords = try buffer.readUInt16()
        let numberOfAuthorities = try buffer.readUInt16()
        let numberOfResources = try buffer.readUInt16()

        guard let resultCode else {
            throw DecoderError.cantReadResultCode(flagsB & 0x0F)
        }

        return DNSHeader(
            id: id,
            isRecursionDesired: isRecursionDesired,
            isMessageTruncated: isMessageTruncated,
            isAnswerAuthorative: isAnswerAuthorative,
            opCode: opCode,
            isResponse: isResponse,
            resultCode: resultCode,
            isCheckingDisabled: isCheckingDisabled,
            isAuthedData: isAuthedData,
            z: z,
            isRecursionAvailable: isRecursionAvailable,
            numberOfQueries: numberOfQueries,
            numberOfRecords: numberOfRecords,
            numberOfAuthorities: numberOfAuthorities,
            numberOfResources: numberOfResources
        )
    }

}

// MARK: - Encoding

extension DNSHeader: DNSPacketEncodable {

    func encode(into buffer: inout ByteBufferWriting) throws {
        buffer.write(id)

        let flagA =
            UInt8(isRecursionDesired ? 1 : 0)
            | (UInt8(isMessageTruncated ? 1 : 0) << 1)
            | (UInt8(isAnswerAuthorative ? 1 : 0) << 2)
            | (opCode << 3)
            | (UInt8(isResponse ? 1 : 0) << 7)
        buffer.write(flagA)

        let flagB =
            resultCode.rawValue
            | (UInt8(isCheckingDisabled ? 1 : 0) << 4)
            | (UInt8(isAuthedData ? 1 : 0) << 5)
            | (UInt8(z ? 1 : 0) << 6)
            | (UInt8(isRecursionAvailable ? 1 : 0) << 7)
        buffer.write(flagB)

        buffer.write(numberOfQueries)
        buffer.write(numberOfRecords)
        buffer.write(numberOfAuthorities)
        buffer.write(numberOfResources)

    }

}
