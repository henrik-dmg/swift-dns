//
//  DNSOperationCode.swift
//  swift-dns
//
//  Created by Henrik Panhans on 20.04.25.
//

/// Represents the op code (OPCODE) in a DNS message header.
///
/// The OPCODE indicates the kind of query in the DNS packet.
/// These codes are defined in RFC 1035 and subsequent RFCs.
public enum DNSOperationCode: Sendable, RawRepresentable, Equatable {

    public typealias RawValue = UInt8

    /// A standard query
    case query

    /// An inverse query
    case inverseQuery

    /// A server status request.
    case status

    /// An other, unknown operation code
    case other(UInt8)

    public var rawValue: UInt8 {
        switch self {
        case .query: 0
        case .inverseQuery: 1
        case .status: 2
        case let .other(value): value
        }
    }

    public init?(rawValue: UInt8) {
        switch rawValue {
        case 0: self = .query
        case 1: self = .inverseQuery
        case 2: self = .status
        default: self = .other(rawValue)
        }
    }

}
