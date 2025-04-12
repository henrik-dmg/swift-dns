//
//  DNSQuery.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

/// Represents a DNS query in the question section of a DNS message.
/// A DNS query consists of a domain name, record type, and record class.
/// This structure is used to specify what information is being requested from a DNS server.
public struct DNSQuery: Equatable {

    // MARK: - Properties

    /// The domain name being queried, represented as DNS labels.
    /// Each label is a string component of the domain name (e.g., ["www", "example", "com"]).
    public var labels: DNSLabels

    /// The type of DNS record being requested (e.g., A, AAAA, MX, etc.).
    /// This determines what kind of information is being queried for the domain.
    public var recordType: DNSRecordType

    /// The class of the record being requested.
    /// For Internet DNS, this is typically IN (Internet) = 1.
    public let recordClass: UInt16

    // MARK: - Init

    /// Creates a new DNS query with the specified parameters.
    ///
    /// - Parameters:
    ///   - labels: An array of strings representing the domain name labels
    ///   - recordType: The type of DNS record being requested
    ///   - recordClass: The class of the record (typically 1 for Internet)
    public init(labels: [String], recordType: DNSRecordType, recordClass: UInt16) {
        self.init(labels: DNSLabels(labels: labels), recordType: recordType, recordClass: recordClass)
    }

    /// Internal initializer that creates a DNS query with pre-constructed DNS labels.
    ///
    /// - Parameters:
    ///   - labels: The DNS labels representing the domain name
    ///   - recordType: The type of DNS record being requested
    ///   - recordClass: The class of the record (typically 1 for Internet)
    init(labels: DNSLabels, recordType: DNSRecordType, recordClass: UInt16) {
        self.labels = labels
        self.recordType = recordType
        self.recordClass = recordClass
    }

}

// MARK: - Decoding

extension DNSQuery: DNSPacketDecodable {

    /// Decodes a DNS query from a byte buffer.
    /// The query is read in the following order:
    /// 1. Domain name (as DNS labels)
    /// 2. Record type
    /// 3. Record class
    ///
    /// - Parameter byteBuffer: The buffer containing the DNS message data
    /// - Returns: A decoded DNSQuery instance
    /// - Throws: An error if the buffer cannot be read or the data is invalid
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

    /// Encodes the DNS query into a byte buffer.
    /// The query is written in the following order:
    /// 1. Domain name (as DNS labels)
    /// 2. Record type
    /// 3. Record class
    ///
    /// - Parameter buffer: The buffer to write the encoded data to
    /// - Throws: An error if the buffer cannot be written to
    func encode(into buffer: inout ByteBufferWriting) throws {
        try buffer.write(labels)
        try recordType.encode(into: &buffer)
        buffer.write(recordClass)
    }

}
