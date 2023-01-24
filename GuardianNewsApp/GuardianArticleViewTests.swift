//
//  GuardianArticleViewTests.swift
//  GuardianNewsAppTests
//
//  Created by Mike Gopsill on 29/03/2021.
//

import SnapshotTesting
import SwiftUI
import XCTest

@testable import GuardianNewsApp

final class GuardianArticleViewTests: XCTestCase {
    func testView() {
        let view = GuardianArticleView(article: .mock())
        let hostingVC = UIHostingController(rootView: view)
        assertSnapshot(matching: hostingVC, as: .image(on: .iPhoneX))
    }
}
