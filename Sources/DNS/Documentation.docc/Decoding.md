# Decoding a DNS Packet

Decoding a ``DNSPacket`` instance from raw `Data` that you received from somewhere.

## Overview

To encode a ``DNSPacket`` instance, use an API similar to that of `JSONDecoder`.
Simply create a new instance of ``DNSPacketDecoder``.

```swift
import DNS

let data: Data // Data you received from somewhere else
let decoder = DNSPacketDecoder() // Create a decoder
let packet = try decoder.decode(from: data)

// Do whatever
print(packet.queries)
print(packet.records)
print(packet.authorities)
print(packet.resources)
```
