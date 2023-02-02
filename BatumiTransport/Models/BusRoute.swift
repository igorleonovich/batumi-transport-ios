//
//  BusRoute.swift
//  BatumiTransport
//
//  Created by Igor Leonovich on 2.02.23.
//

import Foundation

struct BusRoute: Codable {
    
    var routeId: String!
    let coordinates: [[Double]]
    let busStops: [BusStop]
    let buses: [Bus]?
}

extension BusRoute: Equatable {
    
    static func == (lhs: BusRoute, rhs: BusRoute) -> Bool {
        return lhs.routeId == rhs.routeId
    }
}

extension BusRoute: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(routeId)
    }
}

struct BusStop: Codable {
    
    let location: [Double]
    let name: String
    let output: [String: String]
    let stop_id: String
}

extension BusStop: Equatable {
    
    static func == (lhs: BusStop, rhs: BusStop) -> Bool {
        return lhs.stop_id == rhs.stop_id
    }
}

extension BusStop: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(stop_id)
    }
}

struct Bus: Codable {
    
    let c: Int
    let id: String
    let lat: Double
    let lon: Double
    let name: String
    let s: Int
}

struct SimpleBusRoute: Codable {
    
    let number: String
    let id: String
}
