//
//  CustomErrors.swift
//  swift-dns
//
//  Created by Henrik Panhans on 28.07.24.
//

import Foundation

public enum DecoderError: LocalizedError {

    case cantConvertToString(bytes: Data)
    case noLabelsDecoded
    case maximumNumberOfJumpsReached
    case cantReadRecordType(rawValue: UInt16)
    case cantReadResultCode(UInt8)
    case cantReadOpCode(UInt8)
    case invalidIPv6Address(bytes: Data)
    case rdataLengthMismatch(expected: Int, actual: Int)

    public var errorDescription: String? {
        switch self {
        case .cantConvertToString(let bytes): "Can't convert bytes \(bytes.hexEncodedString()) to string"
        case .noLabelsDecoded: "No labels were decoded"
        case .maximumNumberOfJumpsReached: "Maximum number of jumps reached"
        case .cantReadRecordType(let rawValue): "Can't read record type \(rawValue)"
        case .cantReadResultCode(let uInt8): "Can't read result code \(uInt8)"
        case .cantReadOpCode(let uInt8): "Can't read opcode \(uInt8)"
        case .invalidIPv6Address(let bytes): "Invalid IPv6 address \(bytes.hexEncodedString())"
        case .rdataLengthMismatch(let expected, let actual):
            "RDATA length mismatch: expected \(expected) bytes, read \(actual)"
        }
    }

}

public enum EncoderError: LocalizedError {

    case labelTooLong(label: String)
    case cantEncodeLabel(label: String)
    case didNotWriteJumpDirectiveLast
    case unencodableRecordFound(record: any DNSRecord)
    case cantConvertStringToData(String)
    case tooManyRecordsToEncode(count: Int, container: String)

    public var errorDescription: String? {
        switch self {
        case .labelTooLong(let label): "Label \"\(label)\" is too long"
        case .cantEncodeLabel(let label): "Can't connect label \"\(label)\" to ASCII"
        case .didNotWriteJumpDirectiveLast: "Compressor did not write jump directive last, this shouldn't happen"
        case .unencodableRecordFound(let record): "Could not encode record \(record)"
        case .cantConvertStringToData(let string): "Can't convert \"\(string)\" to ASCII data"
        case .tooManyRecordsToEncode(let count, let container):
            "Too many records to encode in container \(container) (\(count) vs \(UInt16.max)"
        }
    }

}
