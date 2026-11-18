# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

swift-dns is a Swift library for working with DNS packets. It enables decoding and encoding DNS packets, building and parsing queries and responses. Built based on Emil Hernvall's [dnsguide](https://github.com/EmilHernvall/dnsguide).

**Product name:** DNS (the library is imported as `import DNS`)

**Platform requirements:**

- macOS 14+
- iOS 16+
- Swift 6.4+

## Common Development Commands

### Building and Testing

```bash
# Build the package
swift build

# Run all tests with verbose output and code coverage
swift test --enable-code-coverage -v

# Run a single test
swift test --filter <TestName>
```

### Code Quality

```bash
# Format Swift code
Scripts/format-swift-code

# Lint Swift code
Scripts/lint-swift-code

# Scan for dead code using Periphery
periphery scan --format github-actions --config config/periphery.yml

# Convert coverage report (macOS only)
Scripts/convert-coverage-report
```

### Documentation

```bash
# Build DocC documentation archive
Scripts/build-docc-archive
```

## Architecture

### Core Encoding/Decoding Pipeline

The library follows a symmetric encode/decode architecture:

**Decoding flow:** `Raw Data` → `ByteBufferReader` → `DNSPacketDecoder` → `DNSPacket`
**Encoding flow:** `DNSPacket` → `DNSPacketEncoder` → `ByteBufferWriter/DNSPacketCompressor` → `Raw Data`

### Key Components

**DNSPacket** (`Sources/DNS/DNSPacket.swift`)

- Central struct representing a complete DNS message (RFC 1035)
- Contains: header, queries, records (answers), authorities, resources (additional)
- All record arrays use `[any DNSRecord]` with custom equality comparison via type-specific casting

**ByteBuffer System** (`Sources/DNS/ByteBuffer/`)

- Protocol-oriented design with separate reading and writing concerns
- `ByteBufferReading`: Used by decoders to read bytes sequentially
- `ByteBufferWriting`: Used by encoders to write bytes
- Implementations: `ByteBufferReader`, `ByteBufferWriter`, `DNSPacketCompressor`

**DNSPacketEncoder** (`Sources/DNS/DNSPacketEncoder.swift`)

- Configurable label compression via `shouldCompressLabels` property
- When compression enabled, uses `DNSPacketCompressor`; otherwise uses `ByteBufferWriter`
- Encodes sections in order: header → queries → records → authorities → resources

**DNSPacketDecoder** (`Sources/DNS/DNSPacketDecoder.swift`)

- Decodes sections sequentially based on header counts
- Uses `DNSRecordDecoder` to decode individual records based on type
- Logs detailed debug info via `Logger.decoder`

**DNS Label Compression** (`Sources/DNS/Helpers/DNSPacketCompressor.swift`)

- Implements RFC 1035 DNS message compression
- Tracks label positions to find reusable suffixes (e.g., reuse ".com" from "google.com" when writing "example.com")
- Uses 2-byte jump pointers with high 2 bits set (0b11) to reference earlier labels
- MUST end in jump directive when compression is used (RFC 1035 section 4.1.4)

**DNS Records** (`Sources/DNS/Records/DNSRecord.swift`)

- Protocol: `DNSRecord` defines common fields (labels, recordType, recordClass, timeToLive, lengthOfCustomData)
- Internal protocol: `DNSRecordEncodable` handles record-specific data encoding
- Supported types: A (IPv4), AAAA (IPv6), NS (name server), CNAME (canonical name), MX (mail exchange), TXT (text), SOA (start of authority), UnknownRecord (fallback)

**DNS Header** (`Sources/DNS/DNSHeader.swift`)

- 12-byte structure containing control flags and section counts
- Bit-packed flags include: QR, OPCODE, AA, TC, RD, RA, Z, RCODE
- Counts: numberOfQueries, numberOfRecords, numberOfAuthorities, numberOfResources

### Design Patterns

1. **Protocol-Oriented Codecs:** `DNSPacketEncodable` and `DNSPacketDecodable` protocols define encode/decode methods that take mutable buffer references
2. **Type Erasure for Records:** Records use `any DNSRecord` with manual type casting for equality checks
3. **Mutable Buffer Pattern:** Encoders/decoders mutate buffer references (`inout`) to maintain state across encoding/decoding operations
4. **Logging:** Uses swift-log with custom loggers (`Logger.decoder`) for debugging packet operations

## Testing

- Test files mirror source structure in `Tests/DNSTests/`
- Test resources (sample DNS packets) stored in `Tests/DNSTests/Resources/`
- Coverage reports generated on macOS via custom script

## CI/CD

- Tests run on both Ubuntu and macOS
- Linting includes swift-format and Periphery dead code scanning
- Documentation automatically built and deployed to GitHub Pages
- All workflows cache SPM dependencies in `.build`

## Coding Guidelines

### Order of Declaration

Structure types in the following order:

- typealiases and associated types
- properties
    - static
    - instance
    - computed
- initialisers
- overridden methods
- methods

For each section, sort by access:

- open/public
- internal
- private

### Formatting

Add an empty line at the beginning and at the end of a type.
