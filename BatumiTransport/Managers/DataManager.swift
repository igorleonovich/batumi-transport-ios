//
//  DataManager.swift
//  BatumiTransport
//
//  Created by Igor Leonovich on 2.02.23.
//

import Foundation

final class DataManager: NSObject {
    
    static let shared = DataManager()
    
    var simpleBusRoutes: [SimpleBusRoute] = [SimpleBusRoute]()
    
    func setup(_ completion: @escaping () -> Void) {
        if let url = Bundle.main.url(forResource: "all-bus-routes", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            if let routes = try? JSONDecoder().decode([SimpleBusRoute].self, from: data) {
                simpleBusRoutes = routes
            }
        }
        completion()
    }
}
