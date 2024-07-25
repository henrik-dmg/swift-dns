//
//  DNSQuery.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

public struct DNSQuery {

    public let labels: DNSLabels
    public let recordType: UInt16
    public let recordClass: UInt16

}

extension DNSQuery: DNSPacketDecodable {

    public static func decode(from byteBuffer: inout ByteBuffer) throws -> DNSQuery {
        DNSQuery(
            labels: try DNSLabels.decode(from: &byteBuffer),
            recordType: try byteBuffer.readUInt16(),
            recordClass: try byteBuffer.readUInt16()
        )
    }

}
