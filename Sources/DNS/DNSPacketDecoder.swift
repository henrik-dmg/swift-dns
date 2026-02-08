//
//  DNSPacketDecoder.swift
//  swift-dns
//
//  Created by Henrik Panhans on 13.04.25.
//

import Foundation
import Logging

/// An object that decodes instances of ``DNSPacket`` from raw `Data`.
public struct DNSPacketDecoder {

    public init() {}

    /// Decodes a DNS packet from raw data.
    ///
    /// The decoding process follows the DNS message format:
    /// 1. Decodes the header section
    /// 2. Decodes the question section based on the number of queries in the header
    /// 3. Decodes the answer section based on the number of records in the header
    /// 4. Decodes the authority section based on the number of authorities in the header
    /// 5. Decodes the additional section based on the number of resources in the header
    ///
    /// - Parameter data: The raw data containing the DNS message
    /// - Returns: A  ``DNSPacket`` instance
    /// - Throws: An error if the data cannot be properly decoded
    public func decode(from data: Data) throws -> DNSPacket {
        Logger.decoder.debug("Received \(data.hexEncodedString())")

        var byteBuffer: any ByteBufferReading = ByteBufferReader(data)

        // Decode the header section
        let header = try DNSHeader.decode(from: &byteBuffer)
        Logger.decoder.debug("\(header)")

        // Decode the question section
        var queries: [DNSQuery] = []
        for _ in 0 ..< header.numberOfQueries {
            let query = try DNSQuery.decode(from: &byteBuffer)
            queries.append(query)
        }

        // Decode the answer section
        var records: [any DNSRecord] = []
        for _ in 0 ..< header.numberOfRecords {
            let record = try DNSRecordDecoder.decode(from: &byteBuffer)
            records.append(record)
        }

        // Decode the authority section
        var authorities: [any DNSRecord] = []
        for _ in 0 ..< header.numberOfAuthorities {
            let record = try DNSRecordDecoder.decode(from: &byteBuffer)
            authorities.append(record)
        }

        // Decode the additional section
        var resources: [any DNSRecord] = []
        for _ in 0 ..< header.numberOfResources {
            let record = try DNSRecordDecoder.decode(from: &byteBuffer)
            resources.append(record)
        }

        Logger.decoder.debug("ByteBuffer has parsed \(byteBuffer.currentIndex)/\(data.count) bytes")

        return DNSPacket(
            header: header,
            queries: queries,
            records: records,
            authorities: authorities,
            resources: resources
        )
    }

}
