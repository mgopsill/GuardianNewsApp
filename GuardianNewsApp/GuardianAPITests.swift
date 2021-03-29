//
//  GuardianAPITests.swift
//  GuardianNewsAppTests
//
//  Created by Mike Gopsill on 28/03/2021.
//

import Combine
import XCTest

@testable import GuardianNewsApp

final class GuardianAPITests: XCTestCase {
    let endpointURL = URL(string: "https://content.guardianapis.com/search")!
    var cancellables = Set<AnyCancellable>()
    
    override class func setUp() {
        super.setUp()
        URLProtocol.registerClass(TestURLProtocol.self)
    }
    
    func testURLComposition() throws {
        var request: URLRequest?
        TestURLProtocol.mockResponses[endpointURL] = {
            request = $0
            return (.success(Data([])), 0)
        }
        
        let expectation = XCTestExpectation()
        GuardianAPI
            .loadNews(page: 0)
            .sink(receiveCompletion: { _ in
                let sentRequest = try! XCTUnwrap(request)
                let queryItems = URLComponents(url: sentRequest.url!, resolvingAgainstBaseURL: false)?.queryItems
                XCTAssertEqual(queryItems?["page"], "0")
                XCTAssertEqual(queryItems?["api-key"], "***REMOVED***")
                XCTAssertEqual(queryItems?["show-fields"], "headline,trailText,body,thumbnail")
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 1)
    }
    
    func testSuccess() throws {
        TestURLProtocol.mockResponses[endpointURL] = { _ in (.success(GuardianAPI.sampleResponse), 200) }

        let expectation = XCTestExpectation()
        GuardianAPI
            .loadNews(page: 0)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure: XCTFail("unexpected error")
                }
            }, receiveValue: { articles in
                XCTAssertEqual(articles.count, 10)
                XCTAssertEqual(articles.first?.fields.headline, "New Zealand v Australia: first women\'s T20 international – live!")
                expectation.fulfill()
            })
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 1)
    }

    func testServerError() throws {
        struct MockError: Error {}
        TestURLProtocol.mockResponses[endpointURL] = { _ in (.failure(MockError()), 440) }

        let expectation = XCTestExpectation()
        GuardianAPI
            .loadNews(page: 0)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("expected failure")
                case .failure(let error):
                    XCTAssertNotNil(error)
                    expectation.fulfill()
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 1)
    }
}

extension GuardianAPI {
    static let sampleResponse: Data = {
        let bundle = Bundle(for: GuardianAPITests.self)
        let url = bundle.url(forResource: "SampleResponse", withExtension: "json")!
        return try! Data(contentsOf: url)
    }()
}

extension Array where Element == URLQueryItem {
  fileprivate subscript(_ name: String) -> String? {
    first(where: { $0.name == name }).flatMap { $0.value }
  }
}
