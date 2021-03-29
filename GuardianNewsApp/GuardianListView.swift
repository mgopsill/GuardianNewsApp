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
                ForEach(viewModel.state.results) { result in
                    HStack {
                        Image(systemName: "house")
                            .frame(width: 50, height: 50)
                        VStack(spacing: 5) {
                            Text(result.fields.headline)
                                .font(.system(size: 12, weight: .bold))
                        
                            Text(result.fields.trailText)
                                .font(.system(size: 10, weight: .light))
                        }
                    }
                    .padding()
                    .onAppear {
                        if viewModel.state.results.last == result {
                            viewModel.loadMoreArticles.send(())
                        }
                    }.onTapGesture {
//                        viewModel.didTap(result: result)
                    }
                }
            }
            .navigationTitle("Guardian")
        //.onAppear(perform: viewModel.loadMoreArticles.send())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GuardianListView(viewModel: GuardianListViewModel())
    }
}
