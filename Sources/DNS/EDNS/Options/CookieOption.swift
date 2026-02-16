//
//  CookieOption.swift
//  swift-dns
//

import Foundation

/// Represents the DNS Cookie EDNS option (RFC 7873).
///
/// DNS cookies provide a lightweight mechanism for DNS servers and clients
/// to verify each other's identity, helping mitigate certain types of
/// DNS abuse such as amplification attacks and cache poisoning.
public struct CookieOption: EDNSOption, EDNSOptionEncodable {

    public let code: EDNSOptionCode = .cookie

    public var dataLength: UInt16 {
        let serverLength = serverCookie?.count ?? 0
        return UInt16(clientCookie.count + serverLength)
    }

    /// The client cookie (exactly 8 bytes).
    public let clientCookie: Data

    /// The server cookie (8 to 32 bytes), or `nil` if not present.
    public let serverCookie: Data?

    /// Creates a new Cookie option.
    ///
    /// - Parameters:
    ///   - clientCookie: The 8-byte client cookie.
    ///   - serverCookie: The optional 8-32 byte server cookie.
    public init(clientCookie: Data, serverCookie: Data? = nil) {
        self.clientCookie = clientCookie
        self.serverCookie = serverCookie
    }

    // MARK: - Encoding

    func encodeOptionData(into buffer: inout ByteBufferWriting) throws(EncoderError) {
        buffer.write(clientCookie)
        if let serverCookie {
            buffer.write(serverCookie)
        }
    }

}
