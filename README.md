# swift-dns

[![codecov](https://codecov.io/gh/henrik-dmg/swift-dns/graph/badge.svg?token=OHrfa9Bgbv)](https://codecov.io/gh/henrik-dmg/swift-dns)
[![Tests](https://github.com/henrik-dmg/swift-dns/actions/workflows/tests.yml/badge.svg)](https://github.com/henrik-dmg/swift-dns/actions/workflows/tests.yml)
[![Linting](https://github.com/henrik-dmg/swift-dns/actions/workflows/linting.yml/badge.svg)](https://github.com/henrik-dmg/swift-dns/actions/workflows/linting.yml)

A Swift library for working with DNS packets. It allows decoding and encoding packets, as well as building and parsing queries and responses.

## Installation

To install the package, add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/henrik-dmg/swift-dns.git", from: "1.0.0")
]
```

Or if you're using Xcode, enter the following URL in the `Package URL` field:

```
https://github.com/henrik-dmg/swift-dns.git
```

## Usage

The documentation can be found at https://henrik-dmg.github.io/swift-dns/documentation/dnskit/

### Decoding a packet

Decoding a packet from bytes is straightforward, simply call `DNSPacket.decode(from:)`.

```swift
import DNSKit

let data: Data // Bytes you received from somewhere else
let decoder = DNSPacketDecoder() // Create a decoder
let packet = try decoder.decode(from: data)

// Do whatever
print(packet.queries)
print(packet.records)
print(packet.authorities)
print(packet.resources)
```

### Encoding a packet

Encoding a packet is just as easy, simply call `DNSPacketEncoder.encode(packet:)`.

```swift
let encoder = DNSPacketEncoder() // Create an encoder
encoder.shouldCompressLabels = false // Disable label compression if you want
let data = try encoder.encode(packet: packet) // Encode the packet
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## Contributors

- [Henrik Panhans](https://github.com/henrik-dmg)
- Hopefully you soon!
