//
//  DNSPacketCodable.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

public protocol DNSPacketEncodable {

    func encode() throws -> Data

}

public protocol DNSPacketDecodable {

    static func decode(from byteBuffer: inout ByteBuffer) throws -> Self

}

public typealias DNSPacketCodable = DNSPacketEncodable & DNSPacketDecodable
