//
//  ByteBuffer.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

public struct ByteBuffer {

    // MARK: - Nested Types

    enum BufferError: LocalizedError {
        case indexOutOfBounds
    }

    // MARK: - Properties

    let data: Data
    private(set) var position: Data.Index = 0

    // MARK: - Init

    public init(_ data: [UInt8]) {
        self.data = Data(data)
    }

    public init(_ data: Data) {
        self.data = data
    }

    // MARK: - Methods

    mutating func seek(_ index: Data.Index) throws {
        guard data.indices.contains(index) else {
            throw BufferError.indexOutOfBounds
        }
        position = index
    }

    mutating func readByte() throws -> UInt8 {
        try readBytes(1)[0]
    }

    mutating func readUInt16() throws -> UInt16 {
        let bytes = try readBytes(2)
        return UInt16(bytes[0]) << 8 + UInt16(bytes[1])
    }

    mutating func readUInt32() throws -> UInt32 {
        UInt32(try readUInt16()) << 16 + UInt32(try readUInt16())
    }

    mutating func readUInt16Wrong() throws -> UInt16 {
        let bytes = Data(try readBytes(2).reversed())
        return bytes.object()
    }

    mutating func readBytes(_ count: Int) throws -> Data {
        guard let endIndex = data.index(position, offsetBy: count, limitedBy: data.endIndex) else {
            throw BufferError.indexOutOfBounds
        }
        let subData = data.subdata(in: position ..< endIndex)
        position = endIndex
        return subData
    }

    func getBytes(_ count: Int) throws -> Data {
        guard let endIndex = data.index(position, offsetBy: count, limitedBy: data.endIndex) else {
            throw BufferError.indexOutOfBounds
        }
        return data.subdata(in: position ..< endIndex)
    }

}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined(separator: " ")
    }
}

extension ContiguousBytes {
    func object<T>() -> T {
        withUnsafeBytes { $0.load(as: T.self) }
    }
}
