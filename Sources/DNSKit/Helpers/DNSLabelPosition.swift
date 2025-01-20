//
//  DNSLabelPosition.swift
//  swift-dns
//
//  Created by Henrik Panhans on 26.07.24.
//

struct DNSLabelPosition: Equatable {

    let index: UInt16
    let label: String

    func areLabelsContinuous(nextLabel: DNSLabelPosition) -> Bool {
        guard let labelData = label.data(using: .ascii) else {
            return false
        }
        let expectedOffset = index + UInt16(labelData.count) + 1  // + 1 because we also write the length of the label
        return nextLabel.index == expectedOffset
    }

}

struct DNSContinuousLabelPosition: Equatable {

    let index: UInt16
    let labels: [String]

}

extension [DNSLabelPosition] {

    func continuousPositions() -> [DNSContinuousLabelPosition] {
        guard !isEmpty else {
            return []
        }

        var continuousGroups: [DNSContinuousLabelPosition] = []
        var labelGroup: [DNSLabelPosition] = [self[0]]

        for position in dropFirst() {
            guard let lastElement = labelGroup.last else {
                continue
            }
            if lastElement.areLabelsContinuous(nextLabel: position) {
                labelGroup.append(position)
            } else {
                let continuousGroup = DNSContinuousLabelPosition(
                    index: labelGroup[0].index,
                    labels: labelGroup.map { $0.label }
                )
                continuousGroups.append(continuousGroup)
                labelGroup = [position]
            }
        }

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
