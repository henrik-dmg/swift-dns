//
//  IPv6Address.swift
//  swift-dns
//
//  Created by Henrik Panhans on 26.07.24.
//

import Foundation

public struct IPv6Address: IPAddress {

    // MARK: - Properties

    public let fragments: [UInt16]

    // MARK: - Init

    init(fragments: [UInt8]) throws {
        guard fragments.count == 16 else {
            throw DecoderError.invalidIPv6Address(bytes: Data(fragments))
        }
        var joinedFragments = [UInt16]()
        for i in 0..<fragments.count where i % 2 == 0 {
            joinedFragments.append(join(fragments[i], fragments[i + 1]))
        }
        self.fragments = joinedFragments
    }

    public init(
        _ octet1: UInt16,
        _ octet2: UInt16,
        _ octet3: UInt16,
        _ octet4: UInt16,
        _ octet5: UInt16,
        _ octet6: UInt16,
        _ octet7: UInt16,
        _ octet8: UInt16
    ) {
        fragments = [
            octet1,
            octet2,
            octet3,
            octet4,
            octet5,
            octet6,
            octet7,
            octet8,
        ]
    }

    // MARK: - Formatting

    public func formattedAddress() -> String {
        var formattedAddress = ""
        let stringFragments = fragments.map { String(format: "%02X", $0) }
        for fragment in stringFragments {
            if fragment != "00" {
                if formattedAddress.last != ":" && !formattedAddress.isEmpty {
                    formattedAddress.append(":")
                }
                formattedAddress += fragment
            } else {
                if formattedAddress.hasSuffix("::") {
                    continue
                } else {
                    formattedAddress += "::"
                }
            }
        }
        return formattedAddress
    }

}

// MARK: - Encoding

extension IPv6Address: DNSPacketEncodable {

    func encode(into byteBuffer: inout any ByteBufferWriting) throws {
        for fragment in self.fragments {
            byteBuffer.write(fragment)
        }
    }

}

// MARK: - CustomDebugStringConvertible

extension IPv6Address: CustomDebugStringConvertible {

    public var debugDescription: String {
        "IPv6(\(formattedAddress())"
    }

}
