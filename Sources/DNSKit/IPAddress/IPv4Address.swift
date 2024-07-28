//
//  IPv4Address.swift
//  swift-dns
//
//  Created by Henrik Panhans on 26.07.24.
//

import Algorithms

public struct IPv4Address: IPAddress {

    // MARK: - Properties

    public let fragments: [UInt8]

    // MARK: - Init

    init(fragments: [UInt8]) {
        self.fragments = fragments
    }

    public init(_ octet1: UInt8, _ octet2: UInt8, _ octet3: UInt8, _ octet4: UInt8) {
        self.init(fragments: [octet1, octet2, octet3, octet4])
    }

    // MARK: - Formatting

    public func formattedAddress() -> String {
        fragments.map { "\($0)" }.joined(separator: ".")
    }

}

// MARK: - Encoding

extension IPv4Address: DNSPacketEncodable {

    func encode(into byteBuffer: inout any ByteBufferWriting) throws {
        byteBuffer.write(fragments)
    }

}

// MARK: - CustomDebugStringConvertible

extension IPv4Address: CustomDebugStringConvertible {

    public var debugDescription: String {
        "IPv4(\(formattedAddress())"
    }

}
