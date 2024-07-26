//
//  ByteBufferProtocol.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

enum ByteBufferError: LocalizedError {
    case indexOutOfBounds
}

public protocol ByteBuffer {

    var data: Data { get }
    var currentIndex: Data.Index { get set }

    mutating func seek(_ index: Data.Index) throws

}

extension ByteBuffer {

    mutating func seek(_ index: Data.Index) throws {
        guard data.indices.contains(index) else {
            throw ByteBufferError.indexOutOfBounds
        }
        currentIndex = index
    }

}
