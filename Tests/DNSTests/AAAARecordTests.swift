//
//  AAAARecordTests.swift
//  swift-dns
//
//  Created by Henrik Panhans on 15.02.26.
//

import DNS
import Testing

@Suite
struct AAAARecordTests {

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
        let address = IPv6Address(0x2606, 0x2800, 0x0220, 0x0001, 0x0248, 0x1893, 0x25c8, 0x1946)
        let record = makeRecord(address: address)
        #expect(record.address.fragments == [0x2606, 0x2800, 0x0220, 0x0001, 0x0248, 0x1893, 0x25c8, 0x1946])
    }

    @Test("record type is AAAA")
    func recordTypeIsAAAA() {
        #expect(makeRecord().recordType == .aaaa)
    }

    @Test("record class defaults to 1")
    func recordClassDefaultsToOne() {
        #expect(makeRecord().recordClass == 1)
    }

    @Test("record class can be customized")
    func recordClassCanBeCustomized() {
        #expect(makeRecord(recordClass: 3).recordClass == 3)
    }

    @Test("length of custom data is 16")
    func lengthOfCustomDataIs16() {
        #expect(makeRecord().lengthOfCustomData == 16)
    }

    @Test("two records with same values are equal")
    func equality() {
        #expect(makeRecord() == makeRecord())
    }

    @Test("two records with different addresses are not equal")
    func inequality() {
        let record1 = makeRecord(address: IPv6Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1))
        let record2 = makeRecord(address: IPv6Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 2))
        #expect(record1 != record2)
    }

    // MARK: - Helpers

    private func makeRecord(
        labels: [String] = ["example", "com"],
        recordClass: UInt16 = 1,
        timeToLive: UInt32 = 300,
        address: IPv6Address = IPv6Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
    ) -> AAAARecord {
        AAAARecord(labels: labels, recordClass: recordClass, timeToLive: timeToLive, address: address)
    }

}
