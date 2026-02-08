//
//  DNSHeader.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

/// Represents the header section of a DNS message as defined in RFC 1035.
///
/// The header contains control information and counts for the various sections of the DNS message.
public struct DNSHeader: Equatable, Sendable {

    /// A 16-bit identifier assigned by the program that generates any kind of query.
    ///
    /// This identifier is copied in the corresponding reply and can be used to match responses with queries.
    public let id: UInt16

    /// Indicates whether the name server should pursue the query recursively.
    ///
    /// If set, the name server will attempt to resolve the query by contacting other name servers if necessary.
    public let isRecursionDesired: Bool

    /// Indicates that the message was truncated due to length greater than that permitted on the transmission channel.
    public let isMessageTruncated: Bool

    /// Indicates that the responding name server is an authority for the domain name in the question section.
    public let isAnswerAuthorative: Bool

    /// Indicates that checking of the response data is disabled.
    public let isCheckingDisabled: Bool

    /// Indicates that the data included in the response is authenticated.
    public let isAuthenticatedData: Bool

    /// Indicates whether recursive query support is available in the name server.
    public let isRecursionAvailable: Bool

    /// A one-bit field that specifies whether this message is a query (0) or a response (1).
    public let isResponse: Bool

    /// A 4-bit field that specifies the kind of query in this message.
    ///
    /// Common values include:
    /// - 0: Standard query (QUERY)
    /// - 1: Inverse query (IQUERY)
    /// - 2: Server status request (STATUS)
    public let operationCode: DNSOperationCode

    /// A 4-bit field that indicates the response code for the query.
    ///
    /// This field is set as part of responses and indicates success or various error conditions.
    public let resultCode: DNSResultCode

    /// Reserved for future use.
    ///
    /// Must be zero in all queries and responses.
    public let z: Bool

    /// The number of entries in the question section of the message.
    public let numberOfQueries: UInt16

    /// The number of resource records in the answer section of the message.
    public let numberOfRecords: UInt16

    /// The number of name server resource records in the authority records section of the message.
    public let numberOfAuthorities: UInt16

    /// The number of resource records in the additional records section of the message.
    public let numberOfResources: UInt16

}

// MARK: - Decoding

extension DNSHeader: DNSPacketDecodable {

    /// Decodes a DNS header from a byte buffer according to the DNS message format specification.
    ///
    /// The header is structured as follows (12 bytes total):
    ///
    /// | RFC Name | Descriptive Name     | Length             |
    /// | -------- | -------------------- | ------------------ |
    /// | ID       | Packet Identifier    | 16 bits            |
    /// | QR       | Query Response       | 1 bit              |
    /// | OPCODE   | Operation Code       | 4 bits             |
    /// | AA       | Authoritative Answer | 1 bit              |
    /// | TC       | Truncated Message    | 1 bit              |
    /// | RD       | Recursion Desired    | 1 bit              |
    /// | RA       | Recursion Available  | 1 bit              |
    /// | Z        | Reserved             | 3 bits             |
    /// | RCODE    | Response Code        | 4 bits             |
    /// | QDCOUNT  | Question Count       | 16 bits            |
    /// | ANCOUNT  | Answer Count         | 16 bits            |
    /// | NSCOUNT  | Authority Count      | 16 bits            |
    /// | ARCOUNT  | Additional Count     | 16 bits            |
    ///
    /// - Parameter buffer: The byte buffer containing the DNS header data
    /// - Returns: A decoded DNSHeader instance
    /// - Throws: ``DecoderError`` if the header cannot be properly decoded
    static func decode(from buffer: inout ByteBufferReading) throws -> DNSHeader {
        // Read the 16-bit message identifier
        let id = try buffer.readUInt16()

        // Read first byte of flags (flagsA)
        let flagsA = try buffer.readByte()
        // Extract individual flags from the first byte
        let isRecursionDesired = (flagsA & (1 << 0)) > 0
        let isMessageTruncated = (flagsA & (1 << 1)) > 0
        let isAnswerAuthorative = (flagsA & (1 << 2)) > 0
        let operationCodeValue = (flagsA >> 3) & 0x0F
        let isResponse = (flagsA & (1 << 7)) > 0

        // Read second byte of flags (flagsB)
        let flagsB = try buffer.readByte()
        // Extract individual flags from the second byte
        let resultCode = DNSResultCode(rawValue: flagsB & 0x0F)
        let isCheckingDisabled = (flagsB & (1 << 4)) > 0
        let isAuthenticatedData = (flagsB & (1 << 5)) > 0
        let z = (flagsB & (1 << 6)) > 0
        let isRecursionAvailable = (flagsB & (1 << 7)) > 0

        // Read the count fields
        let numberOfQueries = try buffer.readUInt16()
        let numberOfRecords = try buffer.readUInt16()
        let numberOfAuthorities = try buffer.readUInt16()
        let numberOfResources = try buffer.readUInt16()

        guard let operationCode = DNSOperationCode(rawValue: operationCodeValue) else {
            throw DecoderError.cantReadOpCode(operationCodeValue)
        }

        // Validate the result code
        guard let resultCode else {
            throw DecoderError.cantReadResultCode(flagsB & 0x0F)
        }

        return DNSHeader(
            id: id,
            isRecursionDesired: isRecursionDesired,
            isMessageTruncated: isMessageTruncated,
            isAnswerAuthorative: isAnswerAuthorative,
            isCheckingDisabled: isCheckingDisabled,
            isAuthenticatedData: isAuthenticatedData,
            isRecursionAvailable: isRecursionAvailable,
            isResponse: isResponse,
            operationCode: operationCode,
            resultCode: resultCode,
            z: z,
            numberOfQueries: numberOfQueries,
            numberOfRecords: numberOfRecords,
            numberOfAuthorities: numberOfAuthorities,
            numberOfResources: numberOfResources
        )
    }

}

// MARK: - Encoding

extension DNSHeader: DNSPacketEncodable {

    /// Encodes the DNS header into a byte buffer according to the DNS message format specification.
    ///
    /// The encoding process follows the same structure as defined in the decoding section.
    ///
    /// - Parameter buffer: The byte buffer to write the encoded header data into
    /// - Throws: An error if the encoding process fails
    func encode(into buffer: inout ByteBufferWriting) throws {
        // Write the message identifier
        buffer.write(id)

        // Encode and write the first byte of flags (flagsA)
        let flagA =
            UInt8(isRecursionDesired ? 1 : 0) | (UInt8(isMessageTruncated ? 1 : 0) << 1)
            | (UInt8(isAnswerAuthorative ? 1 : 0) << 2) | (operationCode.rawValue << 3)
            | (UInt8(isResponse ? 1 : 0) << 7)
        buffer.write(flagA)

        // Encode and write the second byte of flags (flagsB)
        let flagB =
            resultCode.rawValue | (UInt8(isCheckingDisabled ? 1 : 0) << 4)
            | (UInt8(isAuthenticatedData ? 1 : 0) << 5)
            | (UInt8(z ? 1 : 0) << 6) | (UInt8(isRecursionAvailable ? 1 : 0) << 7)
        buffer.write(flagB)

        // Write the count fields
        buffer.write(numberOfQueries)
        buffer.write(numberOfRecords)
        buffer.write(numberOfAuthorities)
        buffer.write(numberOfResources)
    }

}
