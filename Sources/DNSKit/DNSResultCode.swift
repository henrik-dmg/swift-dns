//
//  DNSResultCode.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

// swift-format-ignore: AlwaysUseLowerCamelCase
public enum DNSResultCode: UInt8, Sendable {
    case NOERROR = 0
    case FORMERR = 1
    case SERVFAIL = 2
    case NXDOMAIN = 3
    case NOTIMP = 4
    case REFUSED = 5
}
