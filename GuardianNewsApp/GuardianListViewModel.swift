//
//  GuardianListViewModel.swift
//  GuardianNewsApp
//
//  Created by Mike Gopsill on 28/03/2021.
//

import Combine
import CombineSchedulers
import Foundation

class GuardianListViewModel: ObservableObject {
    typealias API = (Int) -> AnyPublisher<[Article], Error>
    
    // Inputs
    let loadMoreArticles: PassthroughSubject<Void, Never> = .init()
    
    // Outputs
    @Published fileprivate(set) var state = State()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(guardianAPI: @escaping API = GuardianAPI.loadNews,
         scheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()) {
        let fetch = guardianAPI(state.page)
            .share()
        
        let loadMore = loadMoreArticles
            .filter { [unowned self] _ in self.state.canLoadNextPage }
            .flatMap { _ in fetch }
            .eraseToAnyPublisher()
        
        Publishers.Merge(fetch, loadMore)
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
        state.results += batch
        state.page += 1
    }

    struct State {
        var results: [Article] = []
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
