//
//  LabelPositionTests.swift
//  swift-dns
//
//  Created by Henrik Panhans on 26.07.24.
//

import Foundation
import Testing

@testable import DNSKit

@Suite
struct LabelPositionTests {

    @Test
    func continuousLabels() {
        let pos1 = DNSLabelPosition(index: 12, label: "google")
        let pos2 = DNSLabelPosition(index: 19, label: "com")
        #expect(pos1.areLabelsContinuous(nextLabel: pos2))
        #expect(!pos2.areLabelsContinuous(nextLabel: pos1))
    }

    @Test
    func nonContinuousLabels() {
        let pos1 = DNSLabelPosition(index: 12, label: "google")
        let pos2 = DNSLabelPosition(index: 25, label: "com")
        #expect(!pos1.areLabelsContinuous(nextLabel: pos2))
    }

    @Test
    func continuousGroups() {
        let pos1 = DNSLabelPosition(index: 12, label: "google")
        let pos2 = DNSLabelPosition(index: 19, label: "com")
        let pos3 = DNSLabelPosition(index: 54, label: "mail")

        let groups = [pos1, pos2, pos3].continuousPositions()

        #expect(groups.count == 2)
        #expect(groups.first == DNSContinuousLabelPosition(index: 12, labels: ["google", "com"]))
    }

    @Test
    func continuousGroupsSingleElement() {
        let pos1 = DNSLabelPosition(index: 12, label: "google")

        let groups = [pos1].continuousPositions()

        #expect(groups.count == 1)
        #expect(groups.first == DNSContinuousLabelPosition(index: 12, labels: ["google"]))
    }

}
