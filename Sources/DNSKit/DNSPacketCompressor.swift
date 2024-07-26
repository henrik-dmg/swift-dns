//
//  DNSPacketCompressor.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

// This is gonna be the most big-brain shit I'll ever do

import Algorithms
import Foundation

struct DNSPacketCompressor: ByteBufferWriting {

    // MARK: - Nested Types

    enum EncoderError: LocalizedError {
        case labelTooLong(label: String)
        case cantEncodeLabel(label: String)
    }

    // MARK: - Properties

    var byteBuffer: ByteBufferWriter

    var data: Data {
        byteBuffer.data
    }

    var currentIndex: Data.Index {
        get { byteBuffer.currentIndex }
        set { byteBuffer.currentIndex = newValue }
    }

    // MARK: - Init

    init(_ data: Data = Data()) {
        self.byteBuffer = ByteBufferWriter(data)
    }

    // MARK: - Methods

    mutating func write(_ value: UInt32) {
        byteBuffer.write(value)
    }

    mutating func write(_ value: UInt16) {
        byteBuffer.write(value)
    }

    mutating func write(_ value: UInt8) {
        byteBuffer.write(value)
    }

    mutating func write(_ value: Bool) {
        byteBuffer.write(value)
    }

    mutating func write(_ bytes: [UInt8]) {
        byteBuffer.write(bytes)
    }

    mutating func write(_ data: Data) {
        byteBuffer.write(data)
    }

    // MARK: - Label Compresion

    // The code below is very ugly but it works

    mutating func write(_ labels: DNSLabels) throws {
        var remainingLabelsToEncode = labels.labels
        var hasWrittenJumpDirectiveLast = false

        while !remainingLabelsToEncode.isEmpty {
            let labelMatch = findExistingLabel(remainingLabels: remainingLabelsToEncode)

            if let labelMatch {
                let jumpPosition = labelMatch.index ^ (UInt16(DNSLabels.jumpDirective) << 8)
                byteBuffer.write(jumpPosition)
                remainingLabelsToEncode = Array(remainingLabelsToEncode.dropFirst(labelMatch.length))
                hasWrittenJumpDirectiveLast = true
            } else {
                if let firstLabel = remainingLabelsToEncode.first {
                    try writeLabel(firstLabel)
                    remainingLabelsToEncode = Array(remainingLabelsToEncode.dropFirst())
                    hasWrittenJumpDirectiveLast = false
                } else {
                    // TODO: Throw error here because we're out of labels but haven't exited loop
                }
            }
        }

        if !hasWrittenJumpDirectiveLast {
            // Write single zero to signal termination of label sequence
            byteBuffer.write(UInt8(0))
        }
    }

    private mutating func writeLabel(_ label: String) throws {
        let offset = byteBuffer.currentIndex
        try byteBuffer.write(label)
        let labelPosition = LabelPosition(index: UInt16(offset), label: label)
        labelPositions.append(labelPosition)
    }

    private func findExistingLabel(remainingLabels: [String]) -> (index: UInt16, length: Int)? {
        var remainingLabelsToSearchFor = remainingLabels.prefix(labelPositions.count)

        while !remainingLabelsToSearchFor.isEmpty {
            for window in labelPositions.windows(ofCount: remainingLabelsToSearchFor.count) {
                let windowLabels = window.map { $0.label }
                if windowLabels == Array(remainingLabelsToSearchFor.prefix(windowLabels.count)), let firstLabelInWindow = window.first {
                    return (firstLabelInWindow.index, windowLabels.count)
                }
            }
            remainingLabelsToSearchFor = remainingLabelsToSearchFor.dropLast()
        }

        return nil
    }

    var labelPositions: [LabelPosition] = []

    struct LabelPosition {
        let index: UInt16
        let label: String

        func areLabelsContinuous(nextLabel: LabelPosition) -> Bool {
            guard let labelData = label.data(using: .ascii) else {
                return false
            }
            let expectedOffset = index + UInt16(labelData.count) + 1  // + 1 because we also write the length of the label
            return nextLabel.index == expectedOffset
        }
    }

}
