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
    var passthrough = PassthroughSubject<[Article], Error>()
    var subject: GuardianListViewModel!
    var testScheduler: TestSchedulerOf<DispatchQueue>!
    
    enum MockError: Error {
        case test
    }
    
    func mockAPI(page: Int) -> AnyPublisher<[Article], Error> {
        passthrough.eraseToAnyPublisher()
    }
    
    override func setUp() {
        testScheduler = DispatchQueue.testScheduler
        subject = GuardianListViewModel(guardianAPI: mockAPI, scheduler: testScheduler.eraseToAnyScheduler())
    }
    
    override func tearDown() {
        cancellables = nil
        testScheduler = nil
        subject = nil
    }
    
    func testInitialState() {
        XCTAssertEqual(subject.state.results.count, 0)
        XCTAssertEqual(subject.state.page, 1)
        XCTAssertEqual(subject.state.canLoadNextPage, true)
    }
    
    func testFetchingResultsUpdatesState() {
        testScheduler.schedule(after: testScheduler.now.advanced(by: 1)) { [unowned self] in
            self.passthrough.send(Article.mockArticles())
        }
        
        var state: GuardianListViewModel.State?
        subject.$state.sink(receiveValue: { emittedState in
            state = emittedState
        }).store(in: &cancellables)
        
        testScheduler.advance(by: 1)
        XCTAssertEqual(state?.page, 2)
    }
    
    func testLoadMoreArticlesAPICausesLoadFromAPI() {
        var pageRequested: Int?
        let mockAPI: (Int) -> AnyPublisher<[Article], Error> = { int in
            pageRequested = int
            return Just(Article.mockArticles()).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let viewModel = GuardianListViewModel(guardianAPI: mockAPI, scheduler: DispatchQueue.immediateScheduler.eraseToAnyScheduler())
        viewModel.loadMoreArticles.send(())
        XCTAssertEqual(pageRequested, 2)
        
        viewModel.loadMoreArticles.send(())
        XCTAssertEqual(pageRequested, 3)
        
        viewModel.loadMoreArticles.send(())
        XCTAssertEqual(pageRequested, 4)
    }

    func testFetchingMoreResultsUpdatesStateAndAppendsNewResults() {
        testScheduler.schedule(after: testScheduler.now.advanced(by: 1)) { [unowned self] in
            self.passthrough.send(Article.mockArticles())
        }
        
        testScheduler.schedule(after: testScheduler.now.advanced(by: 2)) { [unowned self] in
            self.passthrough.send(Article.mockArticles())
        }
        
        var state: GuardianListViewModel.State?
        subject.$state.sink(receiveValue: { emittedState in
            state = emittedState
        }).store(in: &cancellables)
        
        XCTAssertEqual(state?.page, 1)
        XCTAssertEqual(state?.results.count, 0)
        XCTAssertEqual(state?.canLoadNextPage, true)
        
        testScheduler.advance(by: 1)
        XCTAssertEqual(state?.page, 2)
        XCTAssertEqual(state?.results.count, 5)
        XCTAssertEqual(state?.canLoadNextPage, true)
        
        testScheduler.advance(by: 2)
        XCTAssertEqual(state?.page, 3)
        XCTAssertEqual(state?.results.count, 10)
        XCTAssertEqual(state?.canLoadNextPage, true)
    }
    
    func testFetchingFailsUpdatesStateCantLoadNextPage() {
        testScheduler.schedule(after: testScheduler.now.advanced(by: 1)) { [unowned self] in
            self.passthrough.send(completion: .failure(MockError.test))
        }
        
        var state: GuardianListViewModel.State?
        subject.$state.sink(receiveValue: { emittedState in
            state = emittedState
        }).store(in: &cancellables)
        
        testScheduler.advance(by: 1)
        XCTAssertEqual(state?.page, 1)
        XCTAssertEqual(state?.results.count, 0)
        XCTAssertEqual(state?.canLoadNextPage, false)
    }
    
    func testFetchingFailsUpdatesState_fetchingAgainDoesNothing() {
        testScheduler.schedule(after: testScheduler.now.advanced(by: 1)) { [unowned self] in
            self.passthrough.send(completion: .failure(MockError.test))
        }
        
        testScheduler.schedule(after: testScheduler.now.advanced(by: 2)) { [unowned self] in
            self.passthrough.send(Article.mockArticles())
        }
        
        var state: GuardianListViewModel.State?
        subject.$state.sink(receiveValue: { emittedState in
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
