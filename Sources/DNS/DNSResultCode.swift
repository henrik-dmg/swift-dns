//
//  DNSResultCode.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

/// Represents the response code (RCODE) in a DNS message header.
///
/// The RCODE indicates the success or failure of a DNS query.
/// These codes are defined in RFC 1035 and subsequent RFCs.
public enum DNSResultCode: Sendable, RawRepresentable, Equatable {

    /// No error condition (0)
    /// The query completed successfully.
    case noError

    /// Format Error (1)
    /// The name server was unable to interpret the query due to a format error.
    case formatError

    /// Server Failure (2)
    /// The name server was unable to process this query due to a problem with the name server.
    case serverFailure

    /// Non-Existent Domain (3)
    /// The domain name referenced in the query does not exist.
    case nonExistentDomain

    /// Not Implemented (4)
    /// The name server does not support the requested kind of query.
    case notImplemented

    /// Query Refused (5)
    /// The name server refuses to perform the specified operation for policy reasons.
    case queryRefused

    /// An other, unknown operation code
    case other(UInt8)

    public var rawValue: UInt8 {
        switch self {
        case .noError: 0
        case .formatError: 1
        case .serverFailure: 2
        case .nonExistentDomain: 3
        case .notImplemented: 4
        case .queryRefused: 5
        case let .other(value): value
        }
    }

    public init?(rawValue: UInt8) {
        self =
            switch rawValue {
            case 0: .noError
            case 1: .formatError
            case 2: .serverFailure
            case 3: .nonExistentDomain
            case 4: .notImplemented
            case 5: .queryRefused
            default: .other(rawValue)
            }
    }

}
