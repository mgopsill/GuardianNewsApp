//
//  ResponseModel.swift
//  GuardianNewsApp
//
//  Created by Mike Gopsill on 28/03/2021.
//

import Foundation

struct ResponseModel: Codable {
    let response: Response
}

struct Response: Codable {
    let results: [Article]
}

struct Article: Codable, Identifiable, Equatable {
    let id: String
    let fields: Fields
}

struct Fields: Codable, Equatable {
    let headline, trailText, body: String
    let thumbnail: String?
}

extension Article {
    var imageURL: URL? {
        URL(string: self.fields.thumbnail ?? "")
    }
}
