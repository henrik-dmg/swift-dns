//
//  PTRRecordTests.swift
//  swift-dns
//
//  Created by Henrik Panhans on 15.02.26.
//

import DNS
import Testing

@Suite
struct PTRRecordTests {

    @Test("stores labels from initializer")
    func storesLabels() {
        let record = makeRecord(labels: ["34", "216", "184", "93", "in-addr", "arpa"])
        #expect(record.labels.labels == ["34", "216", "184", "93", "in-addr", "arpa"])
    }

    @Test("stores time to live from initializer")
    func storesTimeToLive() {
        let record = makeRecord(timeToLive: 3600)
        #expect(record.timeToLive == 3600)
    }

    @Test("stores domain name from initializer")
    func storesDomainName() {
        let record = makeRecord(domainName: ["example", "com"])
        #expect(record.domainName.labels == ["example", "com"])
    }

    @Test("record type is PTR")
    func recordTypeIsPTR() {
        #expect(makeRecord().recordType == .ptr)
    }

    @Test("record class defaults to 1")
    func recordClassDefaultsToOne() {
        #expect(makeRecord().recordClass == 1)
    }

    @Test("record class can be customized")
    func recordClassCanBeCustomized() {
        #expect(makeRecord(recordClass: 3).recordClass == 3)
    }

    @Test("computes length of custom data from domain name")
    func computesLengthOfCustomData() {
        let record = makeRecord(domainName: ["host", "example", "com"])
        // "host.example.com": (1+4) + (1+7) + (1+3) + 1 = 18
        #expect(record.lengthOfCustomData == 18)
    }

    @Test("two records with same values are equal")
    func equality() {
        #expect(makeRecord() == makeRecord())
    }

    @Test("two records with different domain names are not equal")
    func inequality() {
        let record1 = makeRecord(domainName: ["host", "example", "com"])
        let record2 = makeRecord(domainName: ["other", "example", "com"])
        #expect(record1 != record2)
    }

    // MARK: - Helpers

    private func makeRecord(
        labels: [String] = ["1", "168", "192", "in-addr", "arpa"],
        recordClass: UInt16 = 1,
        timeToLive: UInt32 = 300,
        domainName: [String] = ["host", "example", "com"]
    ) -> PTRRecord {
        PTRRecord(labels: labels, recordClass: recordClass, timeToLive: timeToLive, domainName: domainName)
    }

}
