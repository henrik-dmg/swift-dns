//
//  DNSPacket.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation
import Logging

/// Represents a complete DNS message packet as defined in RFC 1035.
public struct DNSPacket {

    // MARK: - Properties

    /// The header section of the DNS message, containing control information.
    public let header: DNSHeader

    /// The question section of the DNS message, containing the queries being made.
    public let queries: [DNSQuery]

    /// The answer section of the DNS message, containing resource records that answer the queries.
    public let records: [any DNSRecord]

    /// The authority section of the DNS message, containing name server resource records.
    public let authorities: [any DNSRecord]

    /// The additional section of the DNS message, containing additional resource records.
    public let resources: [any DNSRecord]

}

// MARK: - Init

extension DNSPacket {

    /// Creates a DNS packet by specifying header flags and section arrays.
    ///
    /// The header's section counts are derived automatically from the arrays,
    /// so callers never need to keep them in sync manually.
    ///
    /// ```swift
    /// // Simple query
    /// let packet = try DNSPacket(
    ///     queries: [DNSQuery(labels: ["example", "com"], recordType: .a, recordClass: 1)]
    /// )
    ///
    /// // Authoritative response
    /// let response = try DNSPacket(
    ///     id: request.header.id,
    ///     isResponse: true,
    ///     isRecursionDesired: request.header.isRecursionDesired,
    ///     isRecursionAvailable: true,
    ///     isAnswerAuthoritative: true,
    ///     queries: request.queries,
    ///     records: [resolvedARecord]
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - id: A 16-bit packet identifier. Defaults to a random value.
    ///   - operationCode: The kind of query. Defaults to `.query`.
    ///   - resultCode: The response code. Defaults to `.noError`.
    ///   - isResponse: Whether this packet is a response. Defaults to `false`.
    ///   - isRecursionDesired: Whether recursion is desired. Defaults to `true`.
    ///   - isRecursionAvailable: Whether recursion is available. Defaults to `false`.
    ///   - isAnswerAuthoritative: Whether the answer is authoritative. Defaults to `false`.
    ///   - isMessageTruncated: Whether the message is truncated. Defaults to `false`.
    ///   - isCheckingDisabled: Whether DNSSEC checking is disabled. Defaults to `false`.
    ///   - isAuthenticatedData: Whether the data is DNSSEC-authenticated. Defaults to `false`.
    ///   - queries: The question section entries.
    ///   - records: The answer section resource records.
    ///   - authorities: The authority section resource records.
    ///   - resources: The additional section resource records.
    /// - Throws: Throws an ``EncoderError`` when any of the passed arrays exceed the maximum allowed number of entries  (`UInt16.max`).
    public init(
        id: UInt16 = .random(in: 0 ... UInt16.max),
        operationCode: DNSOperationCode = .query,
        resultCode: DNSResultCode = .noError,
        isResponse: Bool = false,
        isRecursionDesired: Bool = true,
        isRecursionAvailable: Bool = false,
        isAnswerAuthoritative: Bool = false,
        isMessageTruncated: Bool = false,
        isCheckingDisabled: Bool = false,
        isAuthenticatedData: Bool = false,
        queries: [DNSQuery] = [],
        records: [any DNSRecord] = [],
        authorities: [any DNSRecord] = [],
        resources: [any DNSRecord] = []
    ) throws(EncoderError) {
        try Self.validateNumberOfEntries(count: queries.count, container: "queries")
        try Self.validateNumberOfEntries(count: records.count, container: "records")
        try Self.validateNumberOfEntries(count: authorities.count, container: "authorities")
        try Self.validateNumberOfEntries(count: resources.count, container: "resources")

        self.header = DNSHeader(
            id: id,
            isRecursionDesired: isRecursionDesired,
            isMessageTruncated: isMessageTruncated,
            isAnswerAuthoritative: isAnswerAuthoritative,
            isCheckingDisabled: isCheckingDisabled,
            isAuthenticatedData: isAuthenticatedData,
            isRecursionAvailable: isRecursionAvailable,
            isResponse: isResponse,
            operationCode: operationCode,
            resultCode: resultCode,
            z: false,
            numberOfQueries: UInt16(queries.count),
            numberOfRecords: UInt16(records.count),
            numberOfAuthorities: UInt16(authorities.count),
            numberOfResources: UInt16(resources.count)
        )
        self.queries = queries
        self.records = records
        self.authorities = authorities
        self.resources = resources
    }

}

// MARK: - Convenience Factories

extension DNSPacket {

    /// Creates a DNS response packet that mirrors a request's metadata.
    ///
    /// Automatically copies the request's ID, operation code, recursion-desired flag,
    /// and queries so DNS clients can match the response to the original request.
    ///
    /// ```swift
    /// let response = request.makeResponse(
    ///     isRecursionAvailable: true,
    ///     isAnswerAuthoritative: true,
    ///     records: [resolvedARecord]
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - resultCode: The response code. Defaults to `.noError`.
    ///   - isRecursionAvailable: Whether recursion is available. Defaults to `false`.
    ///   - isAnswerAuthoritative: Whether the answer is authoritative. Defaults to `false`.
    ///   - isMessageTruncated: Whether the message is truncated. Defaults to `false`.
    ///   - isCheckingDisabled: Whether DNSSEC checking is disabled. Defaults to `false`.
    ///   - isAuthenticatedData: Whether the data is DNSSEC-authenticated. Defaults to `false`.
    ///   - records: The answer section resource records.
    ///   - authorities: The authority section resource records.
    ///   - resources: The additional section resource records.
    /// - Returns: A DNS response packet.
    /// - Throws: Throws an ``EncoderError`` when any of the passed arrays exceed the maximum number of allowed entries (`UInt16.max`).
    public func makeResponse(
        resultCode: DNSResultCode = .noError,
        isRecursionAvailable: Bool = false,
        isAnswerAuthoritative: Bool = false,
        isMessageTruncated: Bool = false,
        isCheckingDisabled: Bool = false,
        isAuthenticatedData: Bool = false,
        records: [any DNSRecord] = [],
        authorities: [any DNSRecord] = [],
        resources: [any DNSRecord] = []
    ) throws(EncoderError) -> DNSPacket {
        try DNSPacket(
            id: header.id,
            operationCode: header.operationCode,
            resultCode: resultCode,
            isResponse: true,
            isRecursionDesired: header.isRecursionDesired,
            isRecursionAvailable: isRecursionAvailable,
            isAnswerAuthoritative: isAnswerAuthoritative,
            isMessageTruncated: isMessageTruncated,
            isCheckingDisabled: isCheckingDisabled,
            isAuthenticatedData: isAuthenticatedData,
            queries: queries,
            records: records,
            authorities: authorities,
            resources: resources
        )
    }

}

// MARK: - Equatable

extension DNSPacket: Equatable {

    /// Compares two DNS packets for equality.
    ///
    /// Two packets are considered equal if all their sections (header, queries, records, authorities, and resources)
    /// are equal in both content and order.
    public static func == (lhs: DNSPacket, rhs: DNSPacket) -> Bool {
        guard lhs.header == rhs.header && lhs.queries == rhs.queries else {
            return false
        }

        return areRecordArraysEqual(lhs: lhs.records, rhs: rhs.records)
            && areRecordArraysEqual(lhs: lhs.authorities, rhs: rhs.authorities)
            && areRecordArraysEqual(lhs: lhs.resources, rhs: rhs.resources)
    }

    /// Compares two arrays of DNS records for equality.
    ///
    /// The arrays must have the same length and each record at the same index must be equal.
    private static func areRecordArraysEqual(lhs: [any DNSRecord], rhs: [any DNSRecord]) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }

        for (index, record) in lhs.enumerated() {
            let otherRecord = rhs[index]
            if !areRecordsEqual(lhs: record, rhs: otherRecord) {
                return false
            }
        }

        return true
    }

    /// Compares two DNS records for equality.
    ///
    /// The records must be of the same type and have equal content.
    private static func areRecordsEqual(lhs: any DNSRecord, rhs: any DNSRecord) -> Bool {
        guard lhs.recordType == rhs.recordType else {
            return false
        }

        // Compare records based on their specific type
        return switch lhs.recordType {
        case .unknown:
            areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: UnknownRecord.self)
        case .a:
            areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: ARecord.self)
        case .aaaa:
            areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: AAAARecord.self)
        case .ns:
            areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: NSRecord.self)
        case .cname:
            areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: CNAMERecord.self)
        case .mx:
            areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: MXRecord.self)
        case .soa:
            areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: SOARecord.self)
        case .txt:
            areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: TXTRecord.self)
        }
    }

    /// Compares two DNS records of the same specific type for equality.
    private static func areRecordsOfTypeEqual<Record: DNSRecord>(
        lhs: any DNSRecord,
        rhs: any DNSRecord,
        type: Record.Type
    ) -> Bool {
        guard let castedLHS = lhs as? Record, let castedRHS = rhs as? Record else {
            return false
        }
        return castedLHS == castedRHS
    }

}

// MARK: - Validation

extension DNSPacket {

    private static func validateNumberOfEntries(count: Int, container: String) throws(EncoderError) {
        if count > UInt16.max {
            throw EncoderError.tooManyRecordsToEncode(count: count, container: container)
        }
    }

}
