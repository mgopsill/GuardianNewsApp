//
//  TestURLProtocol.swift
//  GuardianNewsAppTests
//
//  Created by Mike Gopsill on 28/03/2021.
//

import Foundation

final class TestURLProtocol: URLProtocol {
    static var mockResponses: [URL: (URLRequest) -> (result: Result<Data, Error>, statusCode: Int?)] = [:]
    
    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url else { return false }
        return mockResponses.keys.contains(url.withoutQueryComponents)
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        guard let responseBlock = TestURLProtocol.mockResponses[request.url!.withoutQueryComponents] else { fatalError("No mock response") }
        let response = responseBlock(request)
        
        if let code = response.statusCode {
            let httpURLResponse = HTTPURLResponse(url: self.request.url!, statusCode: code, httpVersion: nil, headerFields: nil)!
            self.client?.urlProtocol(self, didReceive: httpURLResponse, cacheStoragePolicy: .notAllowed)
        }
        
        switch response.result {
        case let .success(data):
            self.client?.urlProtocol(self, didLoad: data)
            self.client?.urlProtocolDidFinishLoading(self)
            
        case let .failure(error):
            self.client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() { }
}

extension URL {
    fileprivate var withoutQueryComponents: URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        components.queryItems = nil
        return components.url!
    }
}
