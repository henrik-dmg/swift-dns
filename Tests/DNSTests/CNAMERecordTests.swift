//
//  CNAMERecordTests.swift
//  swift-dns
//
//  Created by Henrik Panhans on 15.02.26.
//

import DNS
import Testing

@Suite
struct CNAMERecordTests {

    @Test("stores labels from initializer")
    func storesLabels() {
        let record = makeRecord(labels: ["blog", "example", "com"])
        #expect(record.labels.labels == ["blog", "example", "com"])
    }

    @Test("stores time to live from initializer")
    func storesTimeToLive() {
        let record = makeRecord(timeToLive: 3600)
        #expect(record.timeToLive == 3600)
    }

    @Test("stores payload labels from initializer")
    func storesPayloadLabels() {
        let record = makeRecord(payloadLabels: ["other", "com"])
        #expect(record.payloadLabels.labels == ["other", "com"])
    }

    @Test("record type is CNAME")
    func recordTypeIsCNAME() {
        #expect(makeRecord().recordType == .cname)
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
        let record = makeRecord(payloadLabels: ["example", "com"])
        // "example.com": (1+7) + (1+3) + 1 = 13
        #expect(record.lengthOfCustomData == 13)
    }

    @Test("two records with same values are equal")
    func equality() {
        #expect(makeRecord() == makeRecord())
    }

    @Test("two records with different payload labels are not equal")
    func inequality() {
        let record1 = makeRecord(payloadLabels: ["example", "com"])
        let record2 = makeRecord(payloadLabels: ["other", "com"])
        #expect(record1 != record2)
    }

    // MARK: - Helpers

    private func makeRecord(
        labels: [String] = ["www", "example", "com"],
        recordClass: UInt16 = 1,
        timeToLive: UInt32 = 300,
        payloadLabels: [String] = ["example", "com"]
    ) -> CNAMERecord {
        CNAMERecord(labels: labels, recordClass: recordClass, timeToLive: timeToLive, payloadLabels: payloadLabels)
    }

}
