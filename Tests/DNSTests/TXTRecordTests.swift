//
//  TXTRecordTests.swift
//  swift-dns
//
//  Created by Henrik Panhans on 15.02.26.
//

import DNS
import Testing

@Suite
struct TXTRecordTests {

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

    @Test("stores content from initializer")
    func storesContent() {
        let record = makeRecord(content: "v=spf1 include:_spf.example.com ~all")
        #expect(record.content == "v=spf1 include:_spf.example.com ~all")
    }

    @Test("record type is TXT")
    func recordTypeIsTXT() {
        #expect(makeRecord().recordType == .txt)
    }

    @Test("record class defaults to 1")
    func recordClassDefaultsToOne() {
        #expect(makeRecord().recordClass == 1)
    }

    @Test("record class can be customized")
    func recordClassCanBeCustomized() {
        #expect(makeRecord(recordClass: 3).recordClass == 3)
    }

    @Test("computes length of custom data from content length plus one")
    func computesLengthOfCustomData() {
        let record = makeRecord(content: "hello")
        // 5 (content length) + 1 (length prefix byte) = 6
        #expect(record.lengthOfCustomData == 6)
    }

    @Test("two records with same values are equal")
    func equality() {
        #expect(makeRecord() == makeRecord())
    }

    @Test("two records with different content are not equal")
    func inequality() {
        let record1 = makeRecord(content: "hello")
        let record2 = makeRecord(content: "world")
        #expect(record1 != record2)
    }

    // MARK: - Helpers

    private func makeRecord(
        labels: [String] = ["example", "com"],
        recordClass: UInt16 = 1,
        timeToLive: UInt32 = 300,
        content: String = "v=spf1 ~all"
    ) -> TXTRecord {
        TXTRecord(labels: labels, recordClass: recordClass, timeToLive: timeToLive, content: content)
    }

}
