//
//  DNSQuery.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

public struct DNSQuery: Equatable {

    public let labels: DNSLabels
    public let recordType: DNSRecordType
    public let recordClass: UInt16

}

// MARK: - Decoding

extension DNSQuery: DNSPacketDecodable {

    static func decode(from byteBuffer: inout ByteBufferReading) throws -> DNSQuery {
        DNSQuery(
            labels: try DNSLabels.decode(from: &byteBuffer),
            recordType: try DNSRecordType.decode(from: &byteBuffer),
            recordClass: try byteBuffer.readUInt16()
        )
    }

}

// MARK: - Encoding

extension DNSQuery: DNSPacketEncodable {

    func encode(into byteBuffer: inout ByteBufferWriting) throws {
        try labels.encode(into: &byteBuffer)
        byteBuffer.write(recordType.rawValue)
        byteBuffer.write(recordClass)
    }

}
