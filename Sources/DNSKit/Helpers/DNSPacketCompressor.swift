//
//  DNSPacketCompressor.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

// This is gonna be the most big-brain shit I'll ever do

import Foundation

struct DNSPacketCompressor: ByteBufferWriting {

    // MARK: - Properties

    var byteBuffer: ByteBufferWriter

    var data: Data {
        byteBuffer.data
    }

    var currentIndex: Data.Index {
        byteBuffer.currentIndex
    }

    private var labelPositions: [DNSLabelPosition] = []

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
        var hasWrittenJumpDirective = false
        var labelsSavedByJumpDirective = 0

        while !remainingLabelsToEncode.isEmpty {
            let labelMatchPosition = findExistingLabel(remainingLabels: remainingLabelsToEncode)

            if let labelMatchPosition {
                let jumpPosition = labelMatchPosition.index ^ (UInt16(DNSLabels.jumpDirective) << 8)
                labelsSavedByJumpDirective += labelMatchPosition.labels.count
                byteBuffer.write(jumpPosition)
                remainingLabelsToEncode = Array(remainingLabelsToEncode.dropFirst(labelMatchPosition.labels.count))
                hasWrittenJumpDirectiveLast = true
                hasWrittenJumpDirective = true
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

        guard hasWrittenJumpDirective else {
            // Write single zero to signal termination of label sequence
            byteBuffer.write(UInt8(0))
            return
        }

        if !hasWrittenJumpDirectiveLast {
            throw EncoderError.didNotWriteJumpDirectiveLast
        }
    }

    private mutating func writeLabel(_ label: String) throws {
        let offset = byteBuffer.currentIndex
        try byteBuffer.write(label)
        let labelPosition = DNSLabelPosition(index: UInt16(offset), label: label)
        labelPositions.append(labelPosition)
    }

    private func findExistingLabel(remainingLabels: [String]) -> DNSContinuousLabelPosition? {
        guard !labelPositions.isEmpty else {
            return nil
        }

        let continuousLabelGroups = labelPositions.continuousPositions()

        return continuousLabelGroups.first { labelPosition in
            labelPosition.labels == remainingLabels
        }
    }

}
