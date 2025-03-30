//
//  Logging.swift
//  swift-dns
//
//  Created by Henrik Panhans on 20.01.25.
//

import Logging

extension Logger {

    private static let subsystem: String = "dev.panhans.swift-dns"

    static let dns = Logger(category: "dns")
    static let compressor = Logger(category: "compressor")

    init(category: String) {
        self.init(label: "\(Self.subsystem).\(category)")
    }

}
