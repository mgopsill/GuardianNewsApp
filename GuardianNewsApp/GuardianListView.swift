//
//  GuardianListView.swift
//  GuardianNewsApp
//
//  Created by Mike Gopsill on 28/03/2021.
//

import SwiftUI

struct GuardianListView: View {
    @ObservedObject var viewModel: GuardianListViewModel
    
    var body: some View {
            List {
                ForEach(viewModel.state.article) { article in
                    HStack {
                        LoadableImage(imageLoader: ImageLoader(url: article.imageURL))
                            .frame(width: 50, height: 50)
                        VStack(spacing: 5) {
                            Text(article.fields.headline)
                                .font(.system(size: 12, weight: .bold))
                        
                            Text(article.fields.trailText)
                                .font(.system(size: 10, weight: .light))
                        }
                    }
                    .padding()
                    .onAppear {
                        if viewModel.state.article.last == article {
                            viewModel.loadMoreArticles.send(())
                        }
                    }.onTapGesture {
                        viewModel.tapArticle.send(article)
                    }
                }
            }
            .navigationBarTitle("Guardian")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GuardianListView(viewModel: GuardianListViewModel())
    }
}
