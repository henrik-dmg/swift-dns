# Security Policy

## Supported Versions

Only the latest release of swift-dns gets security fixes.

## Scope

swift-dns decodes DNS packets that come from the network. Thus a malformed packet must never cause a crash, a hang, or
unbounded memory use. Report each of these problems as a security vulnerability.

## Report a Vulnerability

Do not report a security vulnerability in a public issue.

1. Open the [Security tab](https://github.com/henrik-dmg/swift-dns/security) of this repository.
2. Click **Report a vulnerability**.
3. Describe the problem and the steps that reproduce it.
4. If possible, attach the DNS packet that causes the problem.

The report stays private between you and the maintainer until a fix is available.
