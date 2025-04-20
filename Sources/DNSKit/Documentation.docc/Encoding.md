# Encoding a DNS Packet

Encoding a ``DNSPacket`` instance into raw `Data`

## Overview

To encode a ``DNSPacket`` instance, use an API similar to that of `JSONEncoder`.
Simply create a new instance of ``DNSPacketEncoder``.
Additionally you can choose if you want to compress the labels of the records or not.

```swift
let packet = DNSPacket() // Packet you built somewhere or retrieved it
let encoder = DNSPacketEncoder() // Create an encoder
encoder.shouldCompressLabels = false // Disable label compression if you want
let data = try encoder.encode(packet: packet) // Encode the packet
