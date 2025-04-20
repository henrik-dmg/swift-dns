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

protocol ByteBuffer {

    var data: Data { get }
    var currentIndex: Data.Index { get }

}
