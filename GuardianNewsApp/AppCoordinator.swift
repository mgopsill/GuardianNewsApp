//
//  AppCoordinator.swift
//  GuardianNewsApp
//
//  Created by Mike Gopsill on 29/03/2021.
//

import SwiftUI
import UIKit

final class AppCoordinator {
    
    let router: Router
    
    init(router: Router) {
        self.router = router
    }
    
    func start() {
        let viewModel = GuardianListViewModel()
        viewModel.delegate = self
        let viewController = UIHostingController(rootView: GuardianListView(viewModel: viewModel))
        router.pushViewController(viewController, animated: false)
    }
}

extension AppCoordinator: GuardianListViewModelDelegate {
    func didTap(article: Article) {
        let viewController = UIHostingController(rootView: GuardianArticleView(article: article))
        router.pushViewController(viewController, animated: true)
    }
}
