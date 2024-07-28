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
        var continuousGroups: [DNSContinuousLabelPosition] = []
        var labelGroup: [DNSLabelPosition] = []

        if count == 1 {
            return [DNSContinuousLabelPosition(index: self[0].index, labels: [self[0].label])]
        }

        for (lhs, rhs) in self.adjacentPairs() {
            if let lastElement = labelGroup.last, lastElement == lhs {
                // do nothing
            } else {
                labelGroup.append(lhs)
            }

            if lhs.areLabelsContinuous(nextLabel: rhs) {
                labelGroup.append(rhs)
                continue
            } else {
                let continuousGroup = DNSContinuousLabelPosition(index: labelGroup[0].index, labels: labelGroup.map { $0.label })
                continuousGroups.append(continuousGroup)
                labelGroup = [rhs]
            }
        }

        if !labelGroup.isEmpty {
            let continuousGroup = DNSContinuousLabelPosition(index: labelGroup[0].index, labels: labelGroup.map { $0.label })
            continuousGroups.append(continuousGroup)
        }

        return continuousGroups
    }

}
