//
//  IPAddress.swift
//  swift-dns
//
//  Created by Henrik Panhans on 26.07.24.
//

public protocol IPAddress: Equatable, Sendable {

    func formattedAddress() -> String

}
