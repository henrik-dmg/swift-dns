import Foundation
import Logging

/// An object that encodes instances of ``DNSPacket`` as raw `Data`.
public struct DNSPacketEncoder {

    /// Whether to use DNS label compression.
    public var shouldCompressLabels: Bool = true

    public init() {}

    /// Encodes the DNS packet into raw data.
    ///
    /// The encoding process follows the DNS message format and can optionally use label compression
    /// to reduce the size of the message by avoiding repetition of domain names.
    ///
    /// - Parameter packet: The packet to encode
    /// - Returns: The encoded DNS message as raw data
    /// - Throws: An error if the packet cannot be properly encoded
    public func encode(packet: DNSPacket) throws -> Data {
        // Use a compressor if label compression is enabled
        var byteBuffer: any ByteBufferWriting = shouldCompressLabels ? DNSPacketCompressor() : ByteBufferWriter()

        // Encode each section in order
        try packet.header.encode(into: &byteBuffer)

        for query in packet.queries { try query.encode(into: &byteBuffer) }
        for record in packet.records { try record.encode(into: &byteBuffer) }
        for authority in packet.authorities { try authority.encode(into: &byteBuffer) }
        for resource in packet.resources { try resource.encode(into: &byteBuffer) }

        return byteBuffer.data
    }

}
