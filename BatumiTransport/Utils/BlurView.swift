//
//  BlurView.swift
//  BatumiTransport
//
//  Created by Igor Leonovich on 2.02.23.
//

import UIKit

final class BlurView: UIView {
    
    var effectView: UIVisualEffectView?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        NotificationCenter.default.addObserver(self,
            selector: #selector(sceneDidEnterBackground),
            name: Notification.Name("SceneDidEnterBackground"),
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(sceneDidBecomeActive),
            name: Notification.Name("SceneDidBecomeActive"),
            object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func sceneDidEnterBackground() {
        effectView?.alpha = 0
    }
    
    @objc func sceneDidBecomeActive() {
        effectView?.recover()
    }
    
    // MARK: Blur
    
    func addBlur(with intensity: CGFloat = 0.5) {
        backgroundColor = .clear
        let blurVisualEffectView = makeBlur()
        insertSubview(blurVisualEffectView, at: 0)
        blurVisualEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        func makeBlur() -> UIVisualEffectView {
            let blurEffect = UIBlurEffect(style: .dark)
            let effectView = UIVisualEffectView(effect: blurEffect)
            self.effectView = effectView
            effectView.setIntensity(intensity)
            return effectView
        }
    }
}
