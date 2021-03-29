//
//  Router.swift
//  GuardianNewsApp
//
//  Created by Mike Gopsill on 29/03/2021.
//

import UIKit

protocol Router {
    func pushViewController(_ viewController: UIViewController, animated: Bool)
}

extension UINavigationController: Router { }
