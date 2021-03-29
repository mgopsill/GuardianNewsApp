//
//  GuardianListViewModel.swift
//  GuardianNewsApp
//
//  Created by Mike Gopsill on 28/03/2021.
//

import Combine
import CombineSchedulers
import Foundation

protocol GuardianListViewModelDelegate: AnyObject {
    func didTap(article: Article)
}

class GuardianListViewModel: ObservableObject {
    weak var delegate: GuardianListViewModelDelegate?
    
    typealias API = (Int) -> AnyPublisher<[Article], Error>
    
    // Inputs
    let loadMoreArticles: PassthroughSubject<Void, Never> = .init()
    let tapArticle: PassthroughSubject<Article, Never> = .init()
    
    // Outputs
    @Published fileprivate(set) var state = State()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(guardianAPI: @escaping API = GuardianAPI.loadNews,
         scheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()) {
        let loadMore = loadMoreArticles
            .filter { [unowned self] _ in self.state.canLoadNextPage }
            .flatMap({ _ -> AnyPublisher<[Article], Never> in
                guardianAPI(self.state.page)
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
        
        tapArticle.sink { [unowned self] article in
            self.delegate?.didTap(article: article)
        }.store(in: &cancellables)
        
        Publishers.Merge(guardianAPI(state.page), loadMore.setFailureType(to: Error.self))
            .receive(on: scheduler)
            .sink(receiveCompletion: onReceive,
                  receiveValue: onReceive)
            .store(in: &cancellables)
    }
    
    private func onReceive(_ completion: Subscribers.Completion<Error>) {
        switch completion {
        case .finished: break
        case .failure:
            state.canLoadNextPage = false
        }
    }
    
    private func onReceive(_ batch: [Article]) {
        state.article += batch
        state.page += 1
    }

    struct State {
        var article: [Article] = []
        var page: Int = 1
        var canLoadNextPage = true
    }
}

// MARK: - Mocks

#if canImport(XCTest)

  /// A ViewModel subclass used for mocking in snapshot tests.
  ///
  /// It ignores inputs and allows setting the output state manually using the `set(state: State)` method.

  class TestViewModel: GuardianListViewModel {
    func set(state: State) {
      self.state = state
    }

    init() {
        super.init(guardianAPI: { _ in Empty(completeImmediately: false).eraseToAnyPublisher() })
    }
  }
#endif
