//
//  GPS.swift
//  BatumiTransport
//
//  Created by Igor Leonovich on 2.02.23.
//

import Foundation

struct GPS: Codable {
    
    let coordinates: [[Double]]
    let busStops: [BusStop]
    let buses: [Bus]
}

struct BusStop: Codable {
    
    let location: [Double]
    let name: String
    let output: BusStopOutput
    let stop_id: String
}

struct BusStopOutput: Codable {
    
}

struct Bus: Codable {
    
}
