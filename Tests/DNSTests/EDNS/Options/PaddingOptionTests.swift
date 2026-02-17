//
//  PaddingOptionTests.swift
//  swift-dns
//

import DNS
import Foundation
import Testing

@Suite
struct PaddingOptionTests {

    @Test("code is padding")
    func codeIsPadding() {
        #expect(makeOption().code == .padding)
    }

    @Test("stores padding data from initializer")
    func storesPadding() {
        let data = Data([1, 2, 3, 4])
        let option = PaddingOption(padding: data)
        #expect(option.padding == data)
    }

    @Test("length initializer creates zero-filled padding")
    func lengthInitializer() {
        let option = PaddingOption(length: 8)
        #expect(option.padding == Data(count: 8))
    }

    @Test("dataLength matches padding count")
    func dataLength() {
        let option = PaddingOption(length: 16)
        #expect(option.dataLength == 16)
    }

    @Test("two options with same padding are equal")
    func equality() {
        #expect(makeOption() == makeOption())
    }

    @Test("two options with different padding lengths are not equal")
    func inequality() {
        let option1 = PaddingOption(length: 4)
        let option2 = PaddingOption(length: 8)
        #expect(option1 != option2)
    }

    // MARK: - Helpers

    private func makeOption() -> PaddingOption {
        PaddingOption(length: 12)
    }

}
