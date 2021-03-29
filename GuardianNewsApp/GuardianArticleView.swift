//
//  GuardianArticleView.swift
//  GuardianNewsApp
//
//  Created by Mike Gopsill on 29/03/2021.
//

import SwiftUI

struct GuardianArticleView: View {
    let article: Article
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                LoadableImage(imageLoader: ImageLoader(url: article.imageURL))
                Text(article.fields.headline)
                    .font(.headline)
                Text(article.fields.trailText)
                    .font(.subheadline)
                Text(article.fields.body)
                    .font(.system(size: 10, weight: .light))
            }.padding()
        }
    }
}

struct GuardianArticleView_Previews: PreviewProvider {
    static var previews: some View {
        GuardianArticleView(article: Article(id: "0",
                                             fields: Fields(headline: "headline",
                                                            trailText: "sub headline",
                                                            body: "body",
                                                            thumbnail: nil)))
    }
}
