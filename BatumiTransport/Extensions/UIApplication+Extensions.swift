//
//  UIApplication+Extensions.swift
//  BatumiTransport
//
//  Created by Igor Leonovich on 2.02.23.
//

import UIKit

extension UIApplication {
    
    static var sceneDelegate: SceneDelegate? {
        return UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
    }
    
//    static var rootViewController: RootViewController? {
//        return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController as? RootViewController
//    }
    
    static var isLeftToRight: Bool {
        return UIApplication.shared.userInterfaceLayoutDirection == .leftToRight
    }
}
