//
//  Logging.swift
//  swift-dns
//
//  Created by Henrik Panhans on 20.01.25.
//

import Logging

extension Logger {

    private static let subsystem: String = "dev.panhans.swift-dns"

    static let encoder = Logger(category: "encoder")
    static let decoder = Logger(category: "decoder")

    init(category: String) {
        self.init(label: "\(Self.subsystem).\(category)")
    }

}
