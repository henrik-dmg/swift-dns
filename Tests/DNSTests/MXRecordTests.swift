//
//  MXRecordTests.swift
//  swift-dns
//
//  Created by Henrik Panhans on 15.02.26.
//

import DNS
import Testing

@Suite
struct MXRecordTests {

    @Test("stores labels from initializer")
    func storesLabels() {
        let record = makeRecord(labels: ["panhans", "dev"])
        #expect(record.labels.labels == ["panhans", "dev"])
    }

    @Test("stores time to live from initializer")
    func storesTimeToLive() {
        let record = makeRecord(timeToLive: 3600)
        #expect(record.timeToLive == 3600)
    }

    @Test("stores priority from initializer")
    func storesPriority() {
        let record = makeRecord(priority: 20)
        #expect(record.priority == 20)
    }

    @Test("stores payload labels from initializer")
    func storesPayloadLabels() {
        let record = makeRecord(payloadLabels: ["smtp", "example", "com"])
        #expect(record.payloadLabels.labels == ["smtp", "example", "com"])
    }

    @Test("record type is MX")
    func recordTypeIsMX() {
        #expect(makeRecord().recordType == .mx)
    }

    @Test("record class defaults to 1")
    func recordClassDefaultsToOne() {
        #expect(makeRecord().recordClass == 1)
    }

    @Test("record class can be customized")
    func recordClassCanBeCustomized() {
        #expect(makeRecord(recordClass: 3).recordClass == 3)
    }

    @Test("computes length of custom data from priority and payload labels")
    func computesLengthOfCustomData() {
        let record = makeRecord(payloadLabels: ["mail", "example", "com"])
        // 2 (priority) + "mail.example.com": (1+4) + (1+7) + (1+3) + 1 = 2 + 18 = 20
        #expect(record.lengthOfCustomData == 20)
    }

    @Test("two records with same values are equal")
    func equality() {
        #expect(makeRecord() == makeRecord())
    }

    @Test("two records with different priorities are not equal")
    func inequalityPriority() {
        let record1 = makeRecord(priority: 10)
        let record2 = makeRecord(priority: 20)
        #expect(record1 != record2)
    }

    // MARK: - Helpers

    private func makeRecord(
        labels: [String] = ["example", "com"],
        recordClass: UInt16 = 1,
        timeToLive: UInt32 = 300,
        priority: UInt16 = 10,
        payloadLabels: [String] = ["mail", "example", "com"]
    ) -> MXRecord {
        MXRecord(
            labels: labels,
            recordClass: recordClass,
            timeToLive: timeToLive,
            priority: priority,
            payloadLabels: payloadLabels
        )
    }

}
