//
//  ByteBufferWriter.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

public struct ByteBufferWriter: ByteBufferProtocol {

    // MARK: - Properties

    private(set) var data: Data
    var currentIndex: Data.Index = 0

    // MARK: - Init

    public init(_ data: Data = Data()) {
        self.data = data
    }

    // MARK: - Methods

    mutating func write(_ value: UInt32) {
        let firstHalf = UInt16(value >> 16)
        let secondHalf = UInt16(value & 0xFFFF)
        write(firstHalf)
        write(secondHalf)
    }

    mutating func write(_ value: UInt16) {
        let firstHalf = UInt8(value >> 8)
        let secondHalf = UInt8(value & 0xFF)
        data.append(firstHalf)
        data.append(secondHalf)
    }

    mutating func write(_ value: UInt8) {
        data.append(value)
    }

    mutating func write(_ value: Bool) {
        data.append(value ? 1 : 0)
    }

    mutating func write(_ bytes: [UInt8]) {
        data.append(contentsOf: bytes)
    }

    mutating func write(_ data: Data) {
        self.data.append(data)
    }

}
