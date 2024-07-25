//
//  DNSQuery.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

struct DNSQuery {

    let labels: DNSLabels
    let recordType: UInt16
    let recordClass: UInt16

}

extension DNSQuery: DNSPacketDecodable {

    static func decode(from byteBuffer: inout ByteBuffer) throws -> DNSQuery {
        DNSQuery(
            labels: try DNSLabels.decode(from: &byteBuffer),
            recordType: try byteBuffer.readUInt16(),
            recordClass: try byteBuffer.readUInt16()
        )
    }

}
