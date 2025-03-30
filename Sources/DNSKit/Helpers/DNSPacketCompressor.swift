//
//  DNSPacketCompressor.swift
//  swift-dns
//
//  Created by Henrik Panhans on 25.07.24.
//

import Foundation

/// A struct responsible for compressing DNS packets by writing various data types to a byte buffer.
struct DNSPacketCompressor: ByteBufferWriting {

    // MARK: - Properties

    /// The byte buffer writer used to write data.
    var byteBuffer: ByteBufferWriter

    /// The data currently in the byte buffer.
    var data: Data {
        byteBuffer.data
    }

    /// The current index in the byte buffer.
    var currentIndex: Data.Index {
        byteBuffer.currentIndex
    }

    /// An array of label positions used for DNS label compression.
    private var labelPositions: [DNSLabelPosition] = []

    // MARK: - Init

    /// Initializes a new instance of `DNSPacketCompressor` with optional initial data.
    /// - Parameter data: The initial data to write to the byte buffer.
    init(_ data: Data = Data()) {
        self.byteBuffer = ByteBufferWriter(data)
    }

    // MARK: - Methods

    /// Writes a 32-bit unsigned integer to the byte buffer.
    /// - Parameter value: The value to write.
    mutating func write(_ value: UInt32) {
        byteBuffer.write(value)
    }

    /// Writes a 16-bit unsigned integer to the byte buffer.
    /// - Parameter value: The value to write.
    mutating func write(_ value: UInt16) {
        byteBuffer.write(value)
    }

    /// Writes an 8-bit unsigned integer to the byte buffer.
    /// - Parameter value: The value to write.
    mutating func write(_ value: UInt8) {
        byteBuffer.write(value)
    }

    /// Writes a boolean value to the byte buffer.
    /// - Parameter value: The value to write.
    mutating func write(_ value: Bool) {
        byteBuffer.write(value)
    }

    /// Writes an array of bytes to the byte buffer.
    /// - Parameter bytes: The bytes to write.
    mutating func write(_ bytes: [UInt8]) {
        byteBuffer.write(bytes)
    }

    /// Writes data to the byte buffer.
    /// - Parameter data: The data to write.
    mutating func write(_ data: Data) {
        byteBuffer.write(data)
    }

    // MARK: - Label Compression

    /// Writes DNS labels to the byte buffer, using compression if possible.
    /// - Parameter labels: The DNS labels to write.
    /// - Throws: An error if writing the labels fails.
    mutating func write(_ labels: DNSLabels) throws {
        // Labels left to encode (each a domain fragment, e.g., "www", "google", "com")
        var remainingLabelsToEncode = labels.labels

        // Track if the last item written was a compression jump
        var hasWrittenJumpDirectiveLast = false

        // Track if *any* compression jump was used
        var hasWrittenJumpDirective = false

        // For metrics/debugging (not currently used): how many labels were saved by jumping
        var labelsSavedByJumpDirective = 0

        // Loop until all labels are processed
        while !remainingLabelsToEncode.isEmpty {
            // Try to find a previously written label suffix that matches current
            let labelMatchPosition = findExistingLabel(remainingLabels: remainingLabelsToEncode)

            if let labelMatchPosition {
                // Found a match! Apply compression by writing a pointer to the previous position.
                // Compression pointers are 2 bytes, with high 2 bits of first byte set (0b11).
                let jumpPosition = labelMatchPosition.index ^ (UInt16(DNSLabels.jumpDirective) << 8)

                // Write the 2-byte jump offset (pointer to earlier label sequence)
                byteBuffer.write(jumpPosition)

                // Count how many labels were saved
                labelsSavedByJumpDirective += labelMatchPosition.labels.count

                // Remove the matched suffix from the list to encode
                remainingLabelsToEncode = Array(
                    remainingLabelsToEncode.dropFirst(labelMatchPosition.labels.count)
                )

                // Mark that we wrote a jump, and it was the last thing written
                hasWrittenJumpDirectiveLast = true
                hasWrittenJumpDirective = true
            } else {
                guard let firstLabel = remainingLabelsToEncode.first else {
                    // Defensive: This shouldn't happen — if we’re here, something went wrong
                    // TODO: Ideally replace this with a proper thrown error
                    continue
                }

                // No reusable suffix found, so write the label as normal
                try writeLabel(firstLabel)

                // Move on to next label
                remainingLabelsToEncode = Array(remainingLabelsToEncode.dropFirst())

                // Since we wrote a label (not a jump), update tracking
                hasWrittenJumpDirectiveLast = false
            }
        }

        // If no compression was used, terminate with a null label (0x00)
        guard hasWrittenJumpDirective else {
            byteBuffer.write(UInt8(0))  // terminator
            return
        }

        // If compression *was* used, it *must* have ended in a jump (RFC 1035 section 4.1.4)
        if !hasWrittenJumpDirectiveLast {
            throw EncoderError.didNotWriteJumpDirectiveLast
        }
    }

    /// Writes a single DNS label to the byte buffer.
    /// - Parameter label: The label to write.
    /// - Throws: An error if writing the label fails.
    private mutating func writeLabel(_ label: String) throws {
        let offset = byteBuffer.currentIndex
        try byteBuffer.write(label)
        let labelPosition = DNSLabelPosition(index: UInt16(offset), label: label)
        labelPositions.append(labelPosition)
    }

    /// Finds an existing label in the byte buffer that matches the remaining labels.
    /// - Parameter remainingLabels: The remaining labels to find.
    /// - Returns: A continuous label position if a match is found, otherwise nil.
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
