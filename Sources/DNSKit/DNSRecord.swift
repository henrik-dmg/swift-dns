//
//  DNSRecord.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

public protocol DNSRecord {}

public struct DNSUnknownRecord: DNSRecord {
    public let labels: DNSLabels
    public let recordType: UInt16
    public let recordClass: UInt16
    public let timeToLive: UInt32
    public let length: UInt16
}

public struct DNSARecord: DNSRecord {
    public let labels: DNSLabels
    public let recordClass: UInt16
    public let timeToLive: UInt32
    public let ipFragments: [UInt8]
}
