//
//  DNSQuery.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

public struct DNSQuery {

    public let labels: DNSLabels
    public let recordType: DNSRecordType
    public let recordClass: UInt16

}

// MARK: - Decoding

extension DNSQuery: DNSPacketDecodable {

    public static func decode(from byteBuffer: inout ByteBufferReader) throws -> DNSQuery {
        DNSQuery(
            labels: try DNSLabels.decode(from: &byteBuffer),
            recordType: DNSRecordType(rawValue: try byteBuffer.readUInt16()) ?? .unknown,
            recordClass: try byteBuffer.readUInt16()
        )
    }

}

// MARK: - Encoding

extension DNSQuery: DNSPacketEncodable {

    func encode(into byteBuffer: inout ByteBufferWriter) throws {
        try labels.encode(into: &byteBuffer)
        byteBuffer.write(recordType.rawValue)
        byteBuffer.write(recordClass)
    }

}
