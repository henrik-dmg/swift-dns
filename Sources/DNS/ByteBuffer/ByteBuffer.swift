//
//  ByteBufferProtocol.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

protocol ByteBuffer {

    var data: Data { get }
    var currentIndex: Data.Index { get }

}
