//
//  SOARecordTests.swift
//  swift-dns
//
//  Created by Henrik Panhans on 15.02.26.
//

import DNS
import Testing

@Suite
struct SOARecordTests {

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

    @Test("stores primary name server from initializer")
    func storesPrimaryNameServer() {
        let record = makeRecord(primaryNameServer: ["ns2", "example", "com"])
        #expect(record.primaryNameServer.labels == ["ns2", "example", "com"])
    }

    @Test("stores responsible mailbox from initializer")
    func storesResponsibleMailbox() {
        let record = makeRecord(responsibleMailbox: ["hostmaster", "example", "com"])
        #expect(record.responsibleMailbox.labels == ["hostmaster", "example", "com"])
    }

    @Test("stores serial from initializer")
    func storesSerial() {
        let record = makeRecord(serial: 2_024_010_101)
        #expect(record.serial == 2_024_010_101)
    }

    @Test("stores refresh from initializer")
    func storesRefresh() {
        let record = makeRecord(refresh: 14400)
        #expect(record.refresh == 14400)
    }

    @Test("stores retry from initializer")
    func storesRetry() {
        let record = makeRecord(retry: 900)
        #expect(record.retry == 900)
    }

    @Test("stores expire from initializer")
    func storesExpire() {
        let record = makeRecord(expire: 604_800)
        #expect(record.expire == 604_800)
    }

    @Test("stores minimum from initializer")
    func storesMinimum() {
        let record = makeRecord(minimum: 300)
        #expect(record.minimum == 300)
    }

    @Test("record type is SOA")
    func recordTypeIsSOA() {
        #expect(makeRecord().recordType == .soa)
    }

    @Test("record class defaults to 1")
    func recordClassDefaultsToOne() {
        #expect(makeRecord().recordClass == 1)
    }

    @Test("record class can be customized")
    func recordClassCanBeCustomized() {
        #expect(makeRecord(recordClass: 3).recordClass == 3)
    }

    @Test("computes length of custom data from fields")
    func computesLengthOfCustomData() {
        let record = makeRecord()
        // MNAME "ns1.example.com": (1+3) + (1+7) + (1+3) + 1 = 17
        // RNAME "admin.example.com": (1+5) + (1+7) + (1+3) + 1 = 19
        // 5 x UInt32 = 20
        // Total = 56
        #expect(record.lengthOfCustomData == 56)
    }

    @Test("two records with same values are equal")
    func equality() {
        #expect(makeRecord() == makeRecord())
    }

    @Test("two records with different serials are not equal")
    func inequality() {
        let record1 = makeRecord(serial: 1)
        let record2 = makeRecord(serial: 999)
        #expect(record1 != record2)
    }

    // MARK: - Helpers

    private func makeRecord(
        labels: [String] = ["example", "com"],
        recordClass: UInt16 = 1,
        timeToLive: UInt32 = 300,
        primaryNameServer: [String] = ["ns1", "example", "com"],
        responsibleMailbox: [String] = ["admin", "example", "com"],
        serial: UInt32 = 1,
        refresh: UInt32 = 7200,
        retry: UInt32 = 3600,
        expire: UInt32 = 1_209_600,
        minimum: UInt32 = 86400
    ) -> SOARecord {
        SOARecord(
            labels: labels,
            recordClass: recordClass,
            timeToLive: timeToLive,
            primaryNameServer: primaryNameServer,
            responsibleMailbox: responsibleMailbox,
            serial: serial,
            refresh: refresh,
            retry: retry,
            expire: expire,
            minimum: minimum
        )
    }

}
