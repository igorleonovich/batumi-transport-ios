//
//  MainTabViewController.swift
//  BatumiTransport
//
//  Created by Igor Leonovich on 2.02.23.
//

import UIKit

class MainTabViewController: UIViewController {
    
    let topStackView = UIStackView()
    let titleLabel = UILabel()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopStackView()
    }
    
    // MARK: - Setup
    
    private func setupTopStackView() {
        view.addSubview(topStackView)
        topStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(25)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
        }
        topStackView.axis = .horizontal
        topStackView.spacing = 12
        setupTitle()
        topStackView.addArrangedSubview(UIView())
    }
    
    func setupTitle() {
        titleLabel.font = UIFont.systemFont(ofSize: 26)
        titleLabel.textColor = .white
        topStackView.addArrangedSubview(titleLabel)
    }
}
