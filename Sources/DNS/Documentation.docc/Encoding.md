# Encoding a DNS Packet

Encoding a ``DNSPacket`` instance into raw `Data`.

## Overview

Encoding converts a ``DNSPacket`` into raw bytes that can be sent over the network.
This is useful when building a DNS server, forwarding queries to an upstream resolver,
or constructing custom DNS messages.

## Building a Query

Create a query packet using ``DNSPacket/init(id:operationCode:resultCode:isResponse:isRecursionDesired:isRecursionAvailable:isAnswerAuthoritative:isMessageTruncated:isCheckingDisabled:isAuthenticatedData:queries:records:authorities:resources:)``:

```swift
import DNS

let query = try DNSPacket(
    queries: [
        DNSQuery(labels: ["example", "com"], recordType: .a, recordClass: 1)
    ]
)
```

## Building a Response

When you have an incoming request, use ``DNSPacket/makeResponse(resultCode:isRecursionAvailable:isAnswerAuthoritative:isMessageTruncated:isCheckingDisabled:isAuthenticatedData:records:authorities:resources:)``
to build a response that automatically mirrors the request's ID, queries, and flags:

```swift
let response = try request.makeResponse(
    isRecursionAvailable: true,
    isAnswerAuthoritative: true,
    records: [
        ARecord(
            labels: ["example", "com"],
            timeToLive: 300,
            address: IPv4Address(93, 184, 216, 34)
        )
    ]
)
```

## Encoding to Data

Use ``DNSPacketEncoder`` to convert a packet into raw `Data`, similar to `JSONEncoder`:

```swift
let encoder = DNSPacketEncoder()
let data = try encoder.encode(packet: response)
// Send `data` over the network
```

## Label Compression

By default, the encoder compresses domain name labels to reduce packet size
(as specified in RFC 1035). You can disable this if needed:

```swift
let encoder = DNSPacketEncoder()
encoder.shouldCompressLabels = false
let data = try encoder.encode(packet: response)
```

## Error Handling

Encoding can throw an ``EncoderError``. Common cases include:

- ``EncoderError/tooManyRecordsToEncode(count:container:)`` — a section exceeds
  the maximum number of entries (`UInt16.max`).
- ``EncoderError/cantConvertStringToData(_:)`` — a label or text field contains
  non-ASCII characters that cannot be encoded.
