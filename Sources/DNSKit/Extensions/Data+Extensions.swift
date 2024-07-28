//
//  Data+Extensions.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

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

func join(_ lhs: UInt8, rhs: UInt8) -> UInt16 {
    UInt16(lhs) << 8 + UInt16(rhs)
}

func join(_ lhs: UInt16, rhs: UInt16) -> UInt32 {
    UInt32(lhs) << 16 + UInt32(rhs)
}
