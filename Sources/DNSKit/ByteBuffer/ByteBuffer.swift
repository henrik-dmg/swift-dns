//
//  ByteBufferProtocol.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

enum ByteBufferError: LocalizedError {

    case indexOutOfBounds(Data.Index, Data.Index)

    var errorDescription: String? {
        switch self {
        case .indexOutOfBounds(let index, let index2):
            "Data out of bounds requested. Request: \(index), end: \(index2)"
        }
    }

}

public protocol ByteBuffer {

    var data: Data { get }
    var currentIndex: Data.Index { get set }

    mutating func seek(_ index: Data.Index) throws

}

extension ByteBuffer {

    mutating func seek(_ index: Data.Index) throws {
        guard data.indices.contains(index) else {
            throw ByteBufferError.indexOutOfBounds(index, data.endIndex)
        }
        currentIndex = index
    }

}
