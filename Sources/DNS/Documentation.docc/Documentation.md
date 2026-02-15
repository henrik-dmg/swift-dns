# ``DNS``

A Swift library for encoding and decoding DNS packets.

## Overview

``DNS`` provides a complete toolkit for working with DNS messages as defined in
RFC 1035. You can decode raw network data into structured packets, build queries
and responses programmatically, and encode them back into bytes ready to send
over the network.

## Topics

### Articles

- <doc:Encoding>
- <doc:Decoding>

### Packet Structure

- ``DNSPacket``
- ``DNSHeader``
- ``DNSQuery``
- ``DNSLabels``

### Record Types

- ``ARecord``
- ``AAAARecord``
- ``NSRecord``
- ``CNAMERecord``
- ``MXRecord``
- ``TXTRecord``
- ``SOARecord``
- ``PTRRecord``
- ``SRVRecord``

### Supporting Types

- ``DNSRecordType``
- ``DNSOperationCode``
- ``DNSResultCode``
- ``IPv4Address``
- ``IPv6Address``

### Encoding and Decoding

- ``DNSPacketEncoder``
- ``DNSPacketDecoder``
- ``EncoderError``
- ``DecoderError``
