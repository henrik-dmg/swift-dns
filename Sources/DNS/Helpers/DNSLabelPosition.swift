//
//  DNSLabelPosition.swift
//  swift-dns
//
//  Created by Henrik Panhans on 26.07.24.
//

struct DNSLabelPosition: Equatable {

    let index: UInt16  // Byte offset in the DNS packet where this label starts
    let label: String  // The actual label (e.g., "com", "google", etc.)

    /// Checks if the next label is stored immediately after this one,
    /// including its length byte (as required by the DNS label encoding).
    func areLabelsContinuous(nextLabel: DNSLabelPosition) -> Bool {
        guard let labelData = label.data(using: .ascii) else {
            return false
        }

        // Calculate the expected offset of the next label
        // (current index + length byte + label bytes)
        let expectedOffset = index + UInt16(labelData.count) + 1

        // If the next label starts exactly there, they're continuous
        return nextLabel.index == expectedOffset
    }

}

struct DNSContinuousLabelPosition: Equatable {

    let index: UInt16  // Start offset of the first label in the group
    let labels: [String]  // All labels that are consecutively stored

}

extension [DNSLabelPosition] {

    /// Groups label positions that are stored contiguously in the buffer.
    ///
    /// This enables identifying full domains that can be used for compression.
    func continuousPositions() -> [DNSContinuousLabelPosition] {
        guard !isEmpty else {
            return []
        }

        var continuousGroups: [DNSContinuousLabelPosition] = []

        // Initialize the current group with the first label
        var labelGroup: [DNSLabelPosition] = [self[0]]

        for position in dropFirst() {
            guard let lastElement = labelGroup.last else {
                continue
            }

            // Check if this label continues right after the previous
            if lastElement.areLabelsContinuous(nextLabel: position) {
                labelGroup.append(position)
            } else {
                // Finalize current group and start a new one
                let continuousGroup = DNSContinuousLabelPosition(
                    index: labelGroup[0].index,
                    labels: labelGroup.map { $0.label }
                )
                continuousGroups.append(continuousGroup)
                labelGroup = [position]
            }
        }

        // Final group (after loop)
        if !labelGroup.isEmpty {
            let continuousGroup = DNSContinuousLabelPosition(
                index: labelGroup[0].index,
                labels: labelGroup.map { $0.label }
            )
            continuousGroups.append(continuousGroup)
        }

        return continuousGroups
    }

}
