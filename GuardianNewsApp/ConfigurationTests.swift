//
//  ConfigurationTests.swift
//  GuardianNewsAppTests
//
//  Created by Mike Gopsill on 24/01/2023.
//

import XCTest

@testable import GuardianNewsApp

final class ConfigurationTests: XCTestCase {
    
    func testGetApiKeySuccess() {
        let provider: (String) -> Any? = { _ in return "test" }
        let apiKey = getApiKey(from: provider)
        XCTAssertEqual(apiKey, "test")
    }
    
    func testGetApiKeyFailure() {
        let provider: (String) -> Any? = { _ in return nil }
        let apiKey = getApiKey(from: provider)
        XCTAssertTrue(apiKey.isEmpty)
    }
}
