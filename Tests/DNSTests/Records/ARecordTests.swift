//
//  ARecordTests.swift
//  swift-dns
//
//  Created by Henrik Panhans on 15.02.26.
//

import DNS
import Testing

@Suite
struct ARecordTests {

    @Test("stores labels from initializer")
    func storesLabels() {
        let record = makeRecord(labels: ["mail", "google", "com"])
        #expect(record.labels.labels == ["mail", "google", "com"])
    }

    @Test("stores time to live from initializer")
    func storesTimeToLive() {
        let record = makeRecord(timeToLive: 600)
        #expect(record.timeToLive == 600)
    }

    @Test("stores address from initializer")
    func storesAddress() {
        let record = makeRecord(address: IPv4Address(10, 0, 0, 1))
        #expect(record.address.fragments == [10, 0, 0, 1])
    }

    @Test("record type is A")
    func recordTypeIsA() {
        #expect(makeRecord().recordType == .a)
    }

    @Test("record class defaults to 1")
    func recordClassDefaultsToOne() {
        #expect(makeRecord().recordClass == 1)
    }

    @Test("record class can be customized")
    func recordClassCanBeCustomized() {
        #expect(makeRecord(recordClass: 3).recordClass == 3)
    }

    @Test("length of custom data is 4")
    func lengthOfCustomDataIs4() {
        #expect(makeRecord().lengthOfCustomData == 4)
    }

    @Test("two records with same values are equal")
    func equality() {
        #expect(makeRecord() == makeRecord())
    }

    @Test("two records with different addresses are not equal")
    func inequality() {
        let record1 = makeRecord(address: IPv4Address(1, 2, 3, 4))
        let record2 = makeRecord(address: IPv4Address(5, 6, 7, 8))
        #expect(record1 != record2)
    }

    // MARK: - Helpers

    private func makeRecord(
        labels: [String] = ["example", "com"],
        recordClass: UInt16 = 1,
        timeToLive: UInt32 = 300,
        address: IPv4Address = IPv4Address(93, 184, 216, 34)
    ) -> ARecord {
        ARecord(labels: labels, recordClass: recordClass, timeToLive: timeToLive, address: address)
    }

}
