//
//  CustomErrors.swift
//  swift-dns
//
//  Created by Henrik Panhans on 28.07.24.
//

import Foundation

enum DecoderError: LocalizedError {
    case cantConvertToString(bytes: Data)
    case noLabelsDecoded
    case maximumNumberOfJumpsReached
    case cantReadRecordType(rawValue: UInt16)
    case cantReadResultCode(UInt8)
}

enum EncoderError: LocalizedError {

    case labelTooLong(label: String)
    case cantEncodeLabel(label: String)
    case didNotWriteJumpDirectiveLast
    case unencodableRecordFound(record: any DNSRecord)
    case cantConvertStringToData(String)

    var errorDescription: String? {
        switch self {
        case .labelTooLong(let label):
            "Label \"\(label)\" is too long"
        case .cantEncodeLabel(let label):
            "Can't connect label \"\(label)\" to ASCII"
        case .didNotWriteJumpDirectiveLast:
            "Compressor did not write jump directive last, this shouldn't happen"
        case .unencodableRecordFound(let record):
            "Could not encode record \(record)"
        case .cantConvertStringToData(let string):
            "Can't convert \"\(string)\" to ASCII data"
        }
    }

}
