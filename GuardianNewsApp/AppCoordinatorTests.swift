//
//  AppCoordinatorTests.swift
//  GuardianNewsAppTests
//
//  Created by Mike Gopsill on 29/03/2021.
//

import SwiftUI
import XCTest

@testable import GuardianNewsApp

final class AppCoordinatorTests: XCTestCase {
    func testAppCoordinatorStart() {
        let mockRouter = MockRouter()
        let subject = AppCoordinator(router: mockRouter)
        subject.start()
        XCTAssertNotNil(mockRouter.pushedViewController)
        XCTAssertTrue(mockRouter.pushedViewController is UIHostingController<ContentView>)
    }
}

final class MockRouter: Router {
    var pushedViewController: UIViewController?
    func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushedViewController = viewController
    }
}
