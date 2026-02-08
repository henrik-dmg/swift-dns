//
//  IPAddress.swift
//  swift-dns
//
//  Created by Henrik Panhans on 26.07.24.
//

/// A protocol that defines the common interface for IP addresses.
///
/// This protocol is implemented by both IPv4 and IPv6 address types.
/// It provides a standardized way to format and handle IP addresses in the DNS system.
public protocol IPAddress: Equatable, Sendable {

    /// Returns a string representation of the IP address in its standard format.
    ///
    /// For IPv4 addresses, this will be in dotted-decimal notation (e.g., "192.168.1.1").
    /// For IPv6 addresses, this will be in hexadecimal notation with compression (e.g., "2001:db8::1").
    ///
    /// - Returns: A formatted string representation of the IP address
    func formatted() -> String

}
