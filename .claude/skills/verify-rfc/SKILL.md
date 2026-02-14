# Verify RFC Compliance

This skill verifies that swift-dns encoding is RFC-compliant by comparing re-encoded packets against industry-standard dnspython.

## Steps

1. Activate the virtual environment (`.venv`)
2. Ensure dnspython is installed via uv
3. Set the `OUTPUT_ENCODED_PACKETS` environment variable
4. Run the encoding test: `swift test --filter DNSPacketTests/encodePacket`
5. Run the verification script: `Scripts/verify-dns-packets`
6. Clear the `OUTPUT_ENCODED_PACKETS` environment variable
7. Clean up the `tmp/` directory
8. Report results to the user

## Success Criteria

- All tests pass, OR
- Tests fail but verification script confirms packets are semantically equivalent (acceptable compression differences)

## Failure Criteria

- Verification script reports malformed packets or semantic mismatches
- This indicates a bug in the encoder that needs fixing

## Usage

Invoke this skill when:

- Making changes to DNS encoding/decoding logic
- Before merging PRs that affect packet structure
- When debugging encoding issues
- To verify production-readiness of the implementation
