//
//  ByteBufferError.swift
//  swift-dns
//
//  Created by Henrik Panhans on 20.04.25.
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
