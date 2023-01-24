//
//  ImageLoader.swift
//  GuardianNewsApp
//
//  Created by Mike Gopsill on 29/03/2021.
//

import Combine
import CombineSchedulers
import SwiftUI

typealias APIFetcher = (URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError>

extension URLSession {
    func fetch(url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        return dataTaskPublisher(for: url).eraseToAnyPublisher()
    }
}

final class ImageLoader: ObservableObject {
    @Published var image: Image?
    
    var cancellable: AnyCancellable?
        
    init(url: URL?,
         fetcher: APIFetcher = URLSession.shared.fetch(url:),
         scheduler: AnySchedulerOf<RunLoop> = RunLoop.main.eraseToAnyScheduler()) {
        guard let url = url else { return }
        cancellable = fetcher(url)
            .map { $0.data }
            .compactMap { UIImage(data: $0) }
            .map { Image(uiImage: $0) }
            .receive(on: scheduler)
            .replaceError(with: nil)
            .eraseToAnyPublisher()
            .assign(to: \.image, on: self)
    }
}

struct LoadableImage: View {
    @ObservedObject var imageLoader: ImageLoader
    
    init(imageLoader: ImageLoader) {
        self.imageLoader = imageLoader
    }
    
    var body: some View {
        if let image = imageLoader.image {
            return AnyView(
                image.resizable()
                    .aspectRatio(contentMode: .fit)
            )
        } else {
            return AnyView(
                ActivityIndicator(style: .medium)
            )
        }
    }
}

/* Provides the loading animation */
struct ActivityIndicator: UIViewRepresentable {
    let style: UIActivityIndicatorView.Style
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        uiView.startAnimating()
    }
}
