//
//  UIViewController+Extensions.swift
//  BatumiTransport
//
//  Created by Igor Leonovich on 2.02.23.
//

import UIKit

extension UIViewController {
    
    // MARK: Childs
    
    func add(child: UIViewController, containerView: UIView? = nil) {
        addChild(child)
        if let containerView = containerView {
            containerView.addSubview(child.view)
        } else {
            view.addSubview(child.view)
        }
        child.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        child.didMove(toParent: self)
    }

    func remove() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
    // MARK: - Alert
    
    func showAlert(title: String?, message: String?, style preferredStyle: UIAlertController.Style = .alert, actions: [UIAlertAction] = []) {
        let alert = UIViewController.alertController(title: title, message: message, style: preferredStyle, actions: actions)
        DispatchQueue.main.async {
            alert.modalPresentationStyle = .overFullScreen
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showAlert(error: Error) {
        showAlert(title: "Error".localized, message: error.localizedDescription)
    }
    
    static weak var currentAlertController: UIAlertController?
    
    static func alertController(title: String?, message: String?, style preferredStyle: UIAlertController.Style = .alert, actions: [UIAlertAction] = []) -> UIViewController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        if actions.isEmpty {
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
        } else {
            actions.forEach { action in
                alert.addAction(action)
            }
        }
        alert.modalPresentationStyle = .overFullScreen
        currentAlertController = alert
        return alert
    }
}
