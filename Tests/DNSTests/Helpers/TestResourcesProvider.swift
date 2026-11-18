//
//  TestResourcesProvider.swift
//  swift-dns
//
//  Created by Henrik Panhans on 08.02.26.
//

import Foundation

enum TestResourcesProvider {

    static func availableTestResources() -> [String] {
        guard let resourceURL = Bundle.module.resourceURL else {
            return []
        }

        let fileManager = FileManager.default
        guard
            let files = try? fileManager.contentsOfDirectory(
                at: resourceURL,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            )
        else {
            return []
        }

        // On Linux, the resource bundle can also contain a generated Info.plist. Keep only the packet fixtures.
        return
            files
            .map { $0.lastPathComponent }
            .filter { $0.hasPrefix("query-") || $0.hasPrefix("response-") }
            .sorted()
    }

}
