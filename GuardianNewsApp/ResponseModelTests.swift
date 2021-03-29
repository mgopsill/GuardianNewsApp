//
//  ResponseModelTests.swift
//  GuardianNewsAppTests
//
//  Created by Mike Gopsill on 28/03/2021.
//

import XCTest

@testable import GuardianNewsApp

final class ResponseModelTests: XCTestCase {
    func testImageURLNoThumbnail() {
        let fields = Fields(headline: "", trailText: "", body: "", thumbnail: nil)
        let article = Article(id: "", fields: fields)
        let response = Response(results: [article])
        let model = ResponseModel(response: response)
        
        XCTAssertNil(model.response.results.first?.imageURL)
    }
    
    func testImageURLThumbnail() {
        let urlString = "www.google.com"
        let fieldsWithThumbNail = Fields(headline: "", trailText: "", body: "", thumbnail: urlString)
        let article = Article(id: "", fields: fieldsWithThumbNail)
        let response = Response(results: [article])
        let model = ResponseModel(response: response)
        
        XCTAssertEqual(URL(string: urlString), model.response.results.first?.imageURL)
    }
}
