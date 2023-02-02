//
//  BusListViewController.swift
//  BatumiTransport
//
//  Created by Igor Leonovich on 2.02.23.
//

import UIKit

final class BusListViewController: MainTabViewController {
    
    var busRoutes = [SimpleBusRoute]()
    private var tableView: UITableView!
    
    override func loadView() {
        super.loadView()
        view = BlurView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataManager.shared.setup { [weak self] in
            self?.busRoutes = DataManager.shared.simpleBusRoutes
        }
        setupUI()
    }
    
    private func setupUI() {
        (view as? BlurView)?.addBlur(with: 0.2)
        view.backgroundColor = .black.withAlphaComponent(0.8)
        
        tableView = UITableView()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BusRouteCell.self, forCellReuseIdentifier: "BusRouteCell")
        tableView.contentInset = .init(top: 0, left: 0, bottom: MainViewController.bottomPanelHeight + 30, right: 0)
        tableView.backgroundColor = .clear
    }
}

extension BusListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        busRoutes[indexPath.row].id
    }
}


extension BusListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busRoutes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "BusRouteCell", for: indexPath) as? BusRouteCell {
            cell.configure(route: busRoutes[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
}

final class BusRouteCell: TableViewCell {
    
    func configure(route: SimpleBusRoute) {
        textLabel?.textColor = .white
        textLabel?.font = UIFont.systemFont(ofSize: 20, weight: .thin)
        textLabel?.text = "Bus \(route.number)"
    }
}
