//
//  SRVRecordTests.swift
//  swift-dns
//
//  Created by Henrik Panhans on 15.02.26.
//

import DNS
import Testing

@Suite
struct SRVRecordTests {

    @Test("stores labels from initializer")
    func storesLabels() {
        let record = makeRecord(labels: ["_sip", "_tcp", "example", "com"])
        #expect(record.labels.labels == ["_sip", "_tcp", "example", "com"])
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

    @Test("stores weight from initializer")
    func storesWeight() {
        let record = makeRecord(weight: 100)
        #expect(record.weight == 100)
    }

    @Test("stores port from initializer")
    func storesPort() {
        let record = makeRecord(port: 5060)
        #expect(record.port == 5060)
    }

    @Test("stores target from initializer")
    func storesTarget() {
        let record = makeRecord(target: ["sip", "example", "com"])
        #expect(record.target.labels == ["sip", "example", "com"])
    }

    @Test("record type is SRV")
    func recordTypeIsSRV() {
        #expect(makeRecord().recordType == .srv)
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
        let record = makeRecord(target: ["www", "example", "com"])
        // 6 (priority + weight + port) + "www.example.com": (1+3) + (1+7) + (1+3) + 1 = 6 + 17 = 23
        #expect(record.lengthOfCustomData == 23)
    }

    @Test("two records with same values are equal")
    func equality() {
        #expect(makeRecord() == makeRecord())
    }

    @Test("two records with different ports are not equal")
    func inequality() {
        let record1 = makeRecord(port: 80)
        let record2 = makeRecord(port: 443)
        #expect(record1 != record2)
    }

    // MARK: - Helpers

    private func makeRecord(
        labels: [String] = ["_http", "_tcp", "example", "com"],
        recordClass: UInt16 = 1,
        timeToLive: UInt32 = 300,
        priority: UInt16 = 10,
        weight: UInt16 = 60,
        port: UInt16 = 80,
        target: [String] = ["www", "example", "com"]
    ) -> SRVRecord {
        SRVRecord(
            labels: labels,
            recordClass: recordClass,
            timeToLive: timeToLive,
            priority: priority,
            weight: weight,
            port: port,
            target: target
        )
    }

}
