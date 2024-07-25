//
//  DNSPacketCodable.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

public protocol DNSPacketEncodable {

    func encode(into byteBuffer: inout ByteBufferWriter) throws

}

public protocol DNSPacketDecodable {

    associatedtype Value

    static func decode(from byteBuffer: inout ByteBufferReader) throws -> Value

}
