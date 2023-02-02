//
//  RootViewController.swift
//  BatumiTransport
//
//  Created by Igor Leonovich on 2.02.23.
//

import UIKit

final class RootViewController: UIViewController {
    
    private weak var loadingViewController: UIViewController?
    weak var mainNavigationController: UINavigationController?
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoadingViewController()
    }
    
    // MARK: - Loading
    
    private func showLoadingViewController() {
        let loadingViewController = LoadingViewController()
        self.loadingViewController = loadingViewController
        add(child: loadingViewController)
    }
    
    private func removeLoadingViewController() {
        loadingViewController?.remove()
        self.loadingViewController = nil
    }
    
    // MARK: - Main

    func showMainNavigationController() {
        let mainViewController = MainViewController()
        let mainNavigationController = UINavigationController(rootViewController: mainViewController)
        self.mainNavigationController = mainNavigationController
        add(child: mainNavigationController)
        removeLoadingViewController()
    }
}
