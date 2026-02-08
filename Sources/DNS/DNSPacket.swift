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

    /// The header section of the DNS message, containing control information.
    public var header: DNSHeader

    /// The question section of the DNS message, containing the queries being made.
    public var queries: [DNSQuery]

    /// The answer section of the DNS message, containing resource records that answer the queries.
    public var records: [any DNSRecord]

    /// The authority section of the DNS message, containing name server resource records.
    public var authorities: [any DNSRecord]

    /// The additional section of the DNS message, containing additional resource records.
    public var resources: [any DNSRecord]

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
            areRecordsOfTypeEqual(lhs: lhs, rhs: rhs, type: UnknownRecord.self)
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
