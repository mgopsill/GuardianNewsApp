//
//  GuardianAPI.swift
//  GuardianNewsApp
//
//  Created by Mike Gopsill on 28/03/2021.
//

import Combine
import Foundation

enum GuardianAPI {
    static func loadNews(page: Int) -> AnyPublisher<[Article], Error> {
        let request = createRequest(for: page)
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: ResponseModel.self, decoder: JSONDecoder())
            .map(\.response.results)
            .eraseToAnyPublisher()
    }
    
    private static func createRequest(for page: Int) -> URLRequest {
        let baseURL = URL(string: "https://content.guardianapis.com/search")!
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            .init(name: "page", value: "\(page)"),
            .init(name: "api-key", value: "8d6fe5b9-27b1-479e-ab07-9261e0dfa6a4"),
            .init(name: "show-fields", value: "headline,trailText,body,thumbnail"),
        ]
        return URLRequest(url: components.url!)
    }
}
