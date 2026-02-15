# Decoding a DNS Packet

Decoding a ``DNSPacket`` instance from raw `Data` that you received from somewhere.

## Overview

Decoding converts raw bytes received from the network into a structured ``DNSPacket``.
This is useful when building a DNS resolver, inspecting DNS traffic, or processing
responses from an upstream server.

## Basic Decoding

Use ``DNSPacketDecoder`` to decode raw `Data` into a ``DNSPacket``, similar to `JSONDecoder`:

```swift
import DNS

let data: Data // Data you received from the network
let decoder = DNSPacketDecoder()
let packet = try decoder.decode(from: data)
```

## Inspecting the Header

The header contains metadata about the packet, including whether it is a response
and whether the query succeeded:

```swift
let header = packet.header

if header.isResponse {
    print("Result code: \(header.resultCode)")
    print("Authoritative: \(header.isAnswerAuthoritative)")
    print("Answers: \(header.numberOfRecords)")
}
```

## Working with Records

Records are stored as `[any DNSRecord]`. To access type-specific fields, cast to the
concrete record type:

```swift
for record in packet.records {
    switch record {
    case let aRecord as ARecord:
        print("\(aRecord.labels.labels) -> \(aRecord.address)")
    case let mxRecord as MXRecord:
        print("Mail server: \(mxRecord.payloadLabels.labels), priority: \(mxRecord.priority)")
    case let txtRecord as TXTRecord:
        print("TXT: \(txtRecord.content)")
    default:
        print("Record type: \(record.recordType)")
    }
}
```

## Error Handling

Decoding can throw a ``DecoderError``. Common cases include:

- ``DecoderError/maximumNumberOfJumpsReached`` — the packet contains circular
  label compression pointers.
- ``DecoderError/cantConvertToString(bytes:)`` — a label contains invalid ASCII data.
- ``DecoderError/noLabelsDecoded`` — a domain name section contained no labels.
