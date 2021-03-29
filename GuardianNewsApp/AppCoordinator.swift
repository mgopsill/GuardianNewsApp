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
        let viewController = UIHostingController(rootView: ContentView())
        router.pushViewController(viewController, animated: false)
    }
}
