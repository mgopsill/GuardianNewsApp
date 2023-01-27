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
        super.setUp()
        testScheduler = DispatchQueue.test
        subject = GuardianListViewModel(guardianAPI: mockAPI, scheduler: testScheduler.eraseToAnyScheduler())
    }
    
    override func tearDown() {
        cancellables = nil
        testScheduler = nil
        subject = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(subject.state.article.count, 0)
        XCTAssertEqual(subject.state.page, 1)
        XCTAssertEqual(subject.state.canLoadNextPage, true)
    }
    
    func testFetchingResultsUpdatesState() {
        testScheduler.schedule(after: testScheduler.now.advanced(by: 1)) { [unowned self] in
            self.passthrough.send(Article.mockArticles)
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
            return Just(Article.mockArticles).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let viewModel = GuardianListViewModel(guardianAPI: mockAPI, scheduler: DispatchQueue.immediate.eraseToAnyScheduler())
        viewModel.loadMoreArticles.send(())
        XCTAssertEqual(pageRequested, 2)
        
        viewModel.loadMoreArticles.send(())
        XCTAssertEqual(pageRequested, 3)
        
        viewModel.loadMoreArticles.send(())
        XCTAssertEqual(pageRequested, 4)
    }

    func testFetchingMoreResultsUpdatesStateAndAppendsNewResults() {
        testScheduler.schedule(after: testScheduler.now.advanced(by: 1)) { [unowned self] in
            self.passthrough.send(Article.mockArticles)
        }
        
        testScheduler.schedule(after: testScheduler.now.advanced(by: 2)) { [unowned self] in
            self.passthrough.send(Article.mockArticles)
        }
        
        var state: GuardianListViewModel.State?
        subject.$state.sink(receiveValue: { emittedState in
            state = emittedState
        }).store(in: &cancellables)
        
        XCTAssertEqual(state?.page, 1)
        XCTAssertEqual(state?.article.count, 0)
        XCTAssertEqual(state?.canLoadNextPage, true)
        
        testScheduler.advance(by: 1)
        XCTAssertEqual(state?.page, 2)
        XCTAssertEqual(state?.article.count, 5)
        XCTAssertEqual(state?.canLoadNextPage, true)
        
        testScheduler.advance(by: 2)
        XCTAssertEqual(state?.page, 3)
        XCTAssertEqual(state?.article.count, 10)
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
        XCTAssertEqual(state?.article.count, 0)
        XCTAssertEqual(state?.canLoadNextPage, false)
    }
    
    func testFetchingFailsUpdatesState_fetchingAgainDoesNothing() {
        testScheduler.schedule(after: testScheduler.now.advanced(by: 1)) { [unowned self] in
            self.passthrough.send(completion: .failure(MockError.test))
        }
        
        testScheduler.schedule(after: testScheduler.now.advanced(by: 2)) { [unowned self] in
            self.passthrough.send(Article.mockArticles)
        }
        
        var state: GuardianListViewModel.State?
        subject.$state.sink(receiveValue: { emittedState in
            state = emittedState
        }).store(in: &cancellables)
        
        testScheduler.advance(by: 1)
        XCTAssertEqual(state?.page, 1)
        XCTAssertEqual(state?.article.count, 0)
        XCTAssertEqual(state?.canLoadNextPage, false)

        testScheduler.advance(by: 2)
        XCTAssertEqual(state?.page, 1)
        XCTAssertEqual(state?.article.count, 0)
        XCTAssertEqual(state?.canLoadNextPage, false)
    }
    
    func testDidTapArticle() {
        let mockDelegate = MockGuardianListViewModelDelegate()
        subject.delegate = mockDelegate
        
        let article = Article.mock(id: 0)
        subject.tapArticle.send(article)
        XCTAssertEqual(mockDelegate.articleTapped, article)
    }
}

extension Article {
    static func mock(id: Int = 0) -> Article {
        let fields = Fields(headline: "headline", trailText: "text", body: "body", thumbnail: "thumb")
        return Article(id: "\(id)", fields: fields)
    }
    
    static var mockArticles: [Article] {
        (0..<5).map(Article.mock)
    }
}

final class MockGuardianListViewModelDelegate: GuardianListViewModelDelegate {
    var articleTapped: Article?
    func didTap(article: Article) {
        articleTapped = article
    }
}
