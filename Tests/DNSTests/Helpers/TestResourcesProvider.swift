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

        return
            files
            .map { $0.lastPathComponent }
            .filter { !$0.hasPrefix(".") }
            .sorted()
    }

}
