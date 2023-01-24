//
//  SceneDelegate.swift
//  GuardianNewsApp
//
//  Created by Mike Gopsill on 28/03/2021.
//

import UIKit
import SwiftUI

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        appCoordinator = AppCoordinator(router: navigationController)
        appCoordinator.start()
        self.window = window
        window.makeKeyAndVisible()
    }
}
