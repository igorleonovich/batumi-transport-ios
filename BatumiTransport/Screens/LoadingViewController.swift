//
//  LoadingViewController.swift
//  BatumiTransport
//
//  Created by Igor Leonovich on 2.02.23.
//

import UIKit

final class LoadingViewController: UIViewController {
    
//    @IBOutlet weak var loaderView: LottieAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupLoader()
        performLoading()
    }
    
    // MARK: Setup
    
//    private func setupLoader() {
//        loaderView.contentMode = .scaleAspectFill
//        loaderView.loopMode = .loop
//        loaderView.play()
//    }
//
    
    // MARK: Actions
    
    private func performLoading() {
//        DataManager.shared.setup { [weak self] in
//            self?.finishLoading()
//        }
        finishLoading()
    }
    
    private func finishLoading() {
        UIApplication.rootViewController?.showMainNavigationController()
    }
}
