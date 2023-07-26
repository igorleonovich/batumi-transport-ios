//
//  MainViewController.swift
//  BatumiTransport
//
//  Created by Igor Leonovich on 2.02.23.
//

import UIKit

final class MainViewController: UIViewController {
    
    private var viewControllers = [MainTabViewController]()
    var mapViewController: MapViewController!
    private var bottomPanel: BlurView!
    static let bottomPanelHeight: CGFloat = 44
    private var mapStackView: InnerStackView!
    private var busListStackView: InnerStackView!
    
    // MARK: - Life Cycle
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        bottomPanel = BlurView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupMapViewController()
        setupBusListViewController()
        setupBottomPanel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Setup
    
    // TODO: Refector to generics
    private func setupMapViewController() {
        mapViewController = MapViewController()
        viewControllers.append(mapViewController)
        add(child: mapViewController)
    }
    
    private func setupBusListViewController() {
        let busListViewController = BusListViewController()
        busListViewController.mainViewController = self
        viewControllers.append(busListViewController)
        busListViewController.view.alpha = 0
        add(child: busListViewController)
    }
    
    private func setupBottomPanel() {
        view.addSubview(bottomPanel)
        bottomPanel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-68)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        bottomPanel.clipsToBounds = true
        bottomPanel.layer.cornerRadius = 28
        bottomPanel.backgroundColor = .systemBlue.withAlphaComponent(0.66)
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        bottomPanel.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(MainViewController.bottomPanelHeight)
            make.left.equalTo(32)
            make.right.equalTo(-32)
        }
        
        mapStackView = InnerStackView(title: "Map", action: { self.onMap() })
        busListStackView = InnerStackView(title: "Routes", action: { self.onBusList() })
        [mapStackView, busListStackView].forEach { innerStackView in
            guard let innerStackView = innerStackView else { return }
            stackView.addArrangedSubview(innerStackView)
            if innerStackView != mapStackView {
                innerStackView.alpha = 0.4
            }
        }
        
        bottomPanel.addBlur()
    }
    
    // MARK: - Actions: Bottom Panel
    
    func onMap() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        viewControllers.forEach { viewController in
            if viewController.isKind(of: MapViewController.self) {
                viewController.view.alpha = 1
                mapStackView.alpha = 1
            } else {
                viewController.view.alpha = 0
                [busListStackView].forEach({ $0.alpha = 0.4 })
            }
        }
    }
    
    private func onBusList() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        viewControllers.forEach { viewController in
            if viewController.isKind(of: BusListViewController.self) {
                viewController.view.alpha = 1
                busListStackView.alpha = 1
            } else {
//                viewController.view.alpha = 0
                [mapStackView].forEach({ $0.alpha = 0.4 })
            }
        }
    }
    
    private class InnerStackView: UIStackView {
        
        private let title: String
        private let action: () -> Void
        
        init(title: String, action: @escaping () -> Void) {
            self.title = title
            self.action = action
            super.init(frame: .zero)
            setupUI()
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Setup
        
        private func setupUI() {
            axis = .vertical
            spacing = 11

//            setupIcon()
            setupLabel()
            setupGesture()
        }
        
        private func setupIcon() {
            let imageView = UIImageView()
            imageView.image = UIImage(named: title)
            imageView.contentMode = .scaleAspectFit
            addArrangedSubview(imageView)
        }
        
        private func setupLabel() {
            let label = UILabel()
            label.snp.makeConstraints { make in
                make.height.equalTo(13)
            }
            label.text = NSLocalizedString(title, comment: "")
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 18)
            addArrangedSubview(label)
        }
        
        private func setupGesture() {
            let gesture = UITapGestureRecognizer()
            gesture.addTarget(self, action: #selector(onTap))
            addGestureRecognizer(gesture)
        }
        
        @objc func onTap() {
            action()
        }
    }
}
