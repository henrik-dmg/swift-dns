//
//  DNSResultCode.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

// swift-format-ignore: AlwaysUseLowerCamelCase

/// Represents the response code (RCODE) in a DNS message header.
/// The RCODE indicates the success or failure of a DNS query.
/// These codes are defined in RFC 1035 and subsequent RFCs.
public enum DNSResultCode: UInt8, Sendable {

    /// No error condition (0)
    /// The query completed successfully.
    case NOERROR = 0

    /// Format Error (1)
    /// The name server was unable to interpret the query due to a format error.
    case FORMERR = 1

    /// Server Failure (2)
    /// The name server was unable to process this query due to a problem with the name server.
    case SERVFAIL = 2

    /// Non-Existent Domain (3)
    /// The domain name referenced in the query does not exist.
    case NXDOMAIN = 3

    /// Not Implemented (4)
    /// The name server does not support the requested kind of query.
    case NOTIMP = 4

    /// Query Refused (5)
    /// The name server refuses to perform the specified operation for policy reasons.
    case REFUSED = 5

}
