//
//  ByteBufferWriter.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

public struct ByteBufferWriter: ByteBufferProtocol {

    // MARK: - Properties

    var data: Data
    var currentIndex: Data.Index = 0

    // MARK: - Init

    public init(_ data: Data = Data()) {
        self.data = data
    }

    // MARK: - Methods

    mutating func writeUInt16(_ value: UInt16) {
        let firstHalf = UInt8(value >> 8)
        let secondHalf = UInt8(value & 0xFF)
        writeBytes([firstHalf, secondHalf])
    }

    mutating func writeBytes(_ bytes: [UInt8]) {
        data.append(contentsOf: bytes)
    }

}
