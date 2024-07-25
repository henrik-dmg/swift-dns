//
//  DNSHeader.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

//#[derive(Clone, Debug)]
//pub struct DnsHeader {
//    pub id: u16, // 16 bits
//
//    pub recursion_desired: bool,    // 1 bit
//    pub truncated_message: bool,    // 1 bit
//    pub authoritative_answer: bool, // 1 bit
//    pub opcode: u8,                 // 4 bits
//    pub response: bool,             // 1 bit
//
//    pub rescode: ResultCode,       // 4 bits
//    pub checking_disabled: bool,   // 1 bit
//    pub authed_data: bool,         // 1 bit
//    pub z: bool,                   // 1 bit
//    pub recursion_available: bool, // 1 bit
//
//    pub questions: u16,             // 16 bits
//    pub answers: u16,               // 16 bits
//    pub authoritative_entries: u16, // 16 bits
//    pub resource_entries: u16,      // 16 bits
//}

public struct DNSHeader {

    // MARK: - Nested Types

    enum DecodingError: LocalizedError {
        case unknown
        case cantReadResultCode(UInt8)
    }

    // MARK: - Properties

    static let sizeInBytes = 12

    public let id: UInt16
    public let isRecursionDesired: Bool
    public let isMessageTruncated: Bool
    public let isAnswerAuthorative: Bool
    public let opCode: UInt8
    public let isResponse: Bool

    public let resultCode: DNSResultCode
    public let isCheckingDisabled: Bool
    public let isAuthedData: Bool
    public let z: Bool  // I dont know what this is
    public let isRecursionAvailable: Bool

    public let numberOfQueries: UInt16
    public let numberOfRecords: UInt16
    public let numberOfAuthorities: UInt16
    public let numberOfResources: UInt16

}

extension DNSHeader: DNSPacketDecodable {

    /*
     | RFC Name | Descriptive Name     | Length             |
     | -------- | -------------------- | ------------------ |
     | ID       | Packet Identifier    | 16 bits            |
     | QR       | Query Response       | 1 bit              |
     | OPCODE   | Operation Code       | 4 bits             |
     | AA       | Authoritative Answer | 1 bit              |
     | TC       | Truncated Message    | 1 bit              |
     | RD       | Recursion Desired    | 1 bit              |
     | RA       | Recursion Available  | 1 bit              |
     | Z        | Reserved             | 3 bits             |
     | RCODE    | Response Code        | 4 bits             |
     | QDCOUNT  | Question Count       | 16 bits            |
     | ANCOUNT  | Answer Count         | 16 bits            |
     | NSCOUNT  | Authority Count      | 16 bits            |
     | ARCOUNT  | Additional Count     | 16 bits            |
     */
    public static func decode(from byteBuffer: inout ByteBuffer) throws -> DNSHeader {
        let id = try byteBuffer.readUInt16()

        let flagsA = try byteBuffer.readByte()
        let isRecursionDesired = (flagsA & (1 << 0)) > 0
        let isMessageTruncated = (flagsA & (1 << 1)) > 0
        let isAnswerAuthorative = (flagsA & (1 << 2)) > 0
        let opCode = (flagsA >> 3) & 0x0F
        let isResponse = (flagsA & (1 << 7)) > 0

        let flagsB = try byteBuffer.readByte()
        let resultCode = DNSResultCode(rawValue: flagsB & 0x0F)
        let isCheckingDisabled = (flagsB & (1 << 4)) > 0
        let isAuthedData = (flagsB & (1 << 5)) > 0
        let z = (flagsB & (1 << 6)) > 0
        let isRecursionAvailable = (flagsB & (1 << 7)) > 0

        let numberOfQueries = try byteBuffer.readUInt16()
        let numberOfRecords = try byteBuffer.readUInt16()
        let numberOfAuthorities = try byteBuffer.readUInt16()
        let numberOfResources = try byteBuffer.readUInt16()

        guard let resultCode else {
            throw DecodingError.cantReadResultCode(flagsB & 0x0F)
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
