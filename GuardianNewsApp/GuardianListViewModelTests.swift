//
//  GuardianListViewModelTests.swift
//  GuardianNewsAppTests
//
//  Created by Mike Gopsill on 29/03/2021.
//

import Combine
import CombineSchedulers
import XCTest

@testable import GuardianNewsApp

final class GuardianListViewModelTests: XCTestCase {
    var cancellables: Set<AnyCancellable>! = []
    var publishedResult: AnyPublisher<[Article], Error>! = Empty<[Article], Error>().eraseToAnyPublisher()
    var passthrough = PassthroughSubject<[Article], Error>()
    
    enum MockError: Error {
        case test
    }
    
    var pageRequested: Int?
    func mockAPI(page: Int) -> AnyPublisher<[Article], Error> {
        pageRequested = page
        return passthrough.eraseToAnyPublisher()
    }
    
    override func tearDown() {
        cancellables = nil
        publishedResult = nil
    }
    
    func testInitialState() {
        let viewModel = GuardianListViewModel(guardianAPI: mockAPI, scheduler: DispatchQueue.immediateScheduler.eraseToAnyScheduler())
        XCTAssertEqual(viewModel.state.results.count, 0)
        XCTAssertEqual(viewModel.state.page, 1)
        XCTAssertEqual(viewModel.state.canLoadNextPage, true)
    }
    
    func testFetchingResultsUpdatesState() {
        let testScheduler = DispatchQueue.testScheduler

        testScheduler.schedule(after: testScheduler.now.advanced(by: 1)) { [unowned self] in
            self.passthrough.send(Article.mockArticles())
        }
        
        let viewModel = GuardianListViewModel(guardianAPI: mockAPI, scheduler: testScheduler.eraseToAnyScheduler())
        var state: GuardianListViewModel.State?
        viewModel.$state.sink(receiveValue: { emittedState in
            state = emittedState
        }).store(in: &cancellables)
        
        testScheduler.advance(by: 1)
        XCTAssertEqual(state?.page, 2)
    }
    
    func testLoadMoreArticlesAPICausesLoadFromAPI() {
        let viewModel = GuardianListViewModel(guardianAPI: mockAPI, scheduler: DispatchQueue.immediateScheduler.eraseToAnyScheduler())
        
        viewModel.loadMoreArticles.send()
        XCTAssertEqual(pageRequested, 1)
    }

    func testFetchingMoreResultsUpdatesStateAndAppendsNewResults() {
        let testScheduler = DispatchQueue.testScheduler

        testScheduler.schedule(after: testScheduler.now.advanced(by: 1)) { [unowned self] in
            self.passthrough.send(Article.mockArticles())
        }
        
        testScheduler.schedule(after: testScheduler.now.advanced(by: 2)) { [unowned self] in
            self.passthrough.send(Article.mockArticles())
        }
        
        let viewModel = GuardianListViewModel(guardianAPI: mockAPI, scheduler: testScheduler.eraseToAnyScheduler())
        var state: GuardianListViewModel.State?
        viewModel.$state.sink(receiveValue: { emittedState in
            state = emittedState
        }).store(in: &cancellables)
        
        XCTAssertEqual(state?.page, 1)
        
        testScheduler.advance(by: 1)
        XCTAssertEqual(state?.page, 2)
        
        testScheduler.advance(by: 2)
        XCTAssertEqual(state?.page, 3)
    }
    
    func testFetchingFailsUpdatesStateCantLoadNextPage() {
        let testScheduler = DispatchQueue.testScheduler

        testScheduler.schedule(after: testScheduler.now.advanced(by: 1)) { [unowned self] in
            self.passthrough.send(completion: .failure(MockError.test))
        }
        
        let viewModel = GuardianListViewModel(guardianAPI: mockAPI, scheduler: testScheduler.eraseToAnyScheduler())
        var state: GuardianListViewModel.State?
        viewModel.$state.sink(receiveValue: { emittedState in
            state = emittedState
        }).store(in: &cancellables)
        
        testScheduler.advance(by: 1)
        XCTAssertEqual(state?.page, 1)
        XCTAssertEqual(state?.results.count, 0)
        XCTAssertEqual(state?.canLoadNextPage, false)
    }
    
    func testFetchingFailsUpdatesState_fetchingAgainDoesNothing() {
        let testScheduler = DispatchQueue.testScheduler

        testScheduler.schedule(after: testScheduler.now.advanced(by: 1)) { [unowned self] in
            self.passthrough.send(completion: .failure(MockError.test))
        }
        
        testScheduler.schedule(after: testScheduler.now.advanced(by: 2)) { [unowned self] in
            self.passthrough.send(Article.mockArticles())
        }
        
        let viewModel = GuardianListViewModel(guardianAPI: mockAPI, scheduler: testScheduler.eraseToAnyScheduler())
        var state: GuardianListViewModel.State?
        viewModel.$state.sink(receiveValue: { emittedState in
            state = emittedState
        }).store(in: &cancellables)
        
        testScheduler.advance(by: 1)
        XCTAssertEqual(state?.page, 1)
        XCTAssertEqual(state?.results.count, 0)
        XCTAssertEqual(state?.canLoadNextPage, false)

        testScheduler.advance(by: 2)
        XCTAssertEqual(state?.page, 1)
        XCTAssertEqual(state?.results.count, 0)
        XCTAssertEqual(state?.canLoadNextPage, false)
    }
}

extension Article {
    static func mockArticles(count: Int = 5) -> [Article] {
        let fields = Fields(headline: "headline", trailText: "text", body: "body", thumbnail: "thumb")
        return (0..<count).map { Article(id: "\($0)", fields: fields) }
    }
}
