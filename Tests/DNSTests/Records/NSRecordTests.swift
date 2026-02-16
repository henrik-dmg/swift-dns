//
//  NSRecordTests.swift
//  swift-dns
//
//  Created by Henrik Panhans on 15.02.26.
//

import DNS
import Testing

@Suite
struct NSRecordTests {

    @Test("stores labels from initializer")
    func storesLabels() {
        let record = makeRecord(labels: ["panhans", "dev"])
        #expect(record.labels.labels == ["panhans", "dev"])
    }

    @Test("stores time to live from initializer")
    func storesTimeToLive() {
        let record = makeRecord(timeToLive: 86400)
        #expect(record.timeToLive == 86400)
    }

    @Test("stores payload labels from initializer")
    func storesPayloadLabels() {
        let record = makeRecord(payloadLabels: ["ns2", "example", "com"])
        #expect(record.payloadLabels.labels == ["ns2", "example", "com"])
    }

    @Test("record type is NS")
    func recordTypeIsNS() {
        #expect(makeRecord().recordType == .ns)
    }

    @Test("record class defaults to 1")
    func recordClassDefaultsToOne() {
        #expect(makeRecord().recordClass == 1)
    }

    @Test("record class can be customized")
    func recordClassCanBeCustomized() {
        #expect(makeRecord(recordClass: 3).recordClass == 3)
    }

    @Test("computes length of custom data from payload labels")
    func computesLengthOfCustomData() {
        let record = makeRecord(payloadLabels: ["ns1", "example", "com"])
        // "ns1.example.com": (1+3) + (1+7) + (1+3) + 1 = 17
        #expect(record.lengthOfCustomData == 17)
    }

    @Test("two records with same values are equal")
    func equality() {
        #expect(makeRecord() == makeRecord())
    }

    @Test("two records with different payload labels are not equal")
    func inequality() {
        let record1 = makeRecord(payloadLabels: ["ns1", "example", "com"])
        let record2 = makeRecord(payloadLabels: ["ns2", "example", "com"])
        #expect(record1 != record2)
    }

    // MARK: - Helpers

    private func makeRecord(
        labels: [String] = ["example", "com"],
        recordClass: UInt16 = 1,
        timeToLive: UInt32 = 300,
        payloadLabels: [String] = ["ns1", "example", "com"]
    ) -> NSRecord {
        NSRecord(labels: labels, recordClass: recordClass, timeToLive: timeToLive, payloadLabels: payloadLabels)
    }

}
