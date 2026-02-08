//
//  DNSPacketCodable.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

protocol DNSPacketEncodable {

    func encode(into buffer: inout ByteBufferWriting) throws

}

protocol DNSPacketDecodable {

    associatedtype Value

    static func decode(from buffer: inout ByteBufferReading) throws -> Value

}
