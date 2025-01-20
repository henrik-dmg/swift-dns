//
//  Logging.swift
//  swift-dns
//
//  Created by Henrik Panhans on 20.01.25.
//

import OSLog

extension Logger {

    static var dns: Logger {
        Logger(subsystem: "dev.panhans.swift-dns", category: "dns")
    }

}
