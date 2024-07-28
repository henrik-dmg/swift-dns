//
//  DNSQuery.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

public struct DNSQuery: Equatable {

    // MARK: - Properties

    public let labels: DNSLabels
    public let recordType: DNSRecordType
    public let recordClass: UInt16

    // MARK: - Init

    public init(labels: [String], recordType: DNSRecordType, recordClass: UInt16) {
        self.init(labels: DNSLabels(labels: labels), recordType: recordType, recordClass: recordClass)
    }

    init(labels: DNSLabels, recordType: DNSRecordType, recordClass: UInt16) {
        self.labels = labels
        self.recordType = recordType
        self.recordClass = recordClass
    }

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
        try recordType.encode(into: &byteBuffer)
        byteBuffer.write(recordClass)
    }

}
