//
//  GuardianListViewTests.swift
//  GuardianNewsAppTests
//
//  Created by Mike Gopsill on 29/03/2021.
//

import SnapshotTesting
import SwiftUI
import XCTest

@testable import GuardianNewsApp

class GuardianListViewTests: XCTestCase {
    var subject: GuardianListView!
    
    override func tearDown() {
        subject = nil
        super.tearDown()
    }
    
    func testInitial() {
        let vm = TestViewModel()
        subject = GuardianListView(viewModel: vm)
        
        let state = GuardianListViewModel.State(article: [], page: 0, canLoadNextPage: false)
        vm.set(state: state)
        
        let hostingVC = UIHostingController(rootView: subject)
        assertSnapshot(matching: hostingVC, as: .image(on: .iPhoneX))
    }
    
    func testLoaded() {
        let vm = TestViewModel()
        subject = GuardianListView(viewModel: vm)
        
        let state = GuardianListViewModel.State(article: Article.mockArticles, page: 0, canLoadNextPage: false)
        vm.set(state: state)
        
        let hostingVC = UIHostingController(rootView: subject)
        assertSnapshot(matching: hostingVC, as: .image(on: .iPhoneX))
    }
}
