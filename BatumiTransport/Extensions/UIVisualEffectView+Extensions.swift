import UIKit

extension UIVisualEffectView {
    
    private var key: UnsafeRawPointer? { UnsafeRawPointer(bitPattern: 16) }

    private var interface: VisualEffectViewInterface {
        if let key = key, let visualEffectViewInterface = objc_getAssociatedObject(self, key) as? VisualEffectViewInterface {
            return visualEffectViewInterface
        }
        let visualEffectViewInterface = VisualEffectViewInterface()
        
        if let key = key {
            objc_setAssociatedObject(self, key, visualEffectViewInterface, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        return visualEffectViewInterface
    }

    func setIntensity(_ intensity: CGFloat) {
        interface.setIntensity(effectView: self, intensity: intensity)
    }
    
    func recover() {
        interface.recover()
    }
    
    final private class VisualEffectViewInterface {
        
        private var animator: UIViewPropertyAnimator!
        private var intensity: CGFloat = 0
        private var effectView: UIVisualEffectView?
        
        func setIntensity(effectView: UIVisualEffectView, intensity: CGFloat) {
            self.intensity = intensity
            self.effectView = effectView
            let effect = effectView.effect
            effectView.effect = nil
            animator?.stopAnimation(true)
            animator = UIViewPropertyAnimator(duration: 0.25, curve: .linear) { [weak effectView] in effectView?.effect = effect }
            animator.fractionComplete = intensity
        }
        
        func recover() {
            guard let effectView = effectView else { return }
            self.setIntensity(effectView: effectView, intensity: self.intensity)
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.effectView?.alpha = 1
            }
        }
    }
}
