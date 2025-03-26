//
//  dns-resolver.swift
//  swift-dns
//
//  Created by Henrik Panhans on 24.03.25.
//

import ArgumentParser
import DNSKit
import AsyncDNSResolver
import RegexBuilder

@main
struct DNSResolver: AsyncParsableCommand {

    enum QueryType: String, Codable, ExpressibleByArgument {
        case A, MX, NS, TXT, SOA
    }

    @Argument(help: "The domain to query")
    var domain: String

    @Argument(help: "The query type (A, MX, NS, TXT, SOA)")
    var queries: [QueryType]

    func run() async throws {
        // Initialize a resolver
        let resolver = try AsyncDNSResolver()

        for query in queries {
            print("Querying \(query.rawValue) for \(domain)")
            switch query {
            case .A:
                print(try await resolver.queryA(name: domain))
            case .MX:
                print(try await resolver.queryMX(name: domain))
            case .NS:
                print(try await resolver.queryNS(name: domain))
            case .TXT:
                print(try await resolver.queryTXT(name: domain))
            default:
                break
            }
        }
    }

}
