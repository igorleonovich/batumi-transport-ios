//
//  MapViewController.swift
//  BatumiTransport
//
//  Created by Igor Leonovich on 2.02.23.
//

import GoogleMaps
import UIKit

final class MapViewController: UIViewController {

    private var mapView: GMSMapView!
    private var initialCoordinates: CLLocationCoordinate2D? {
        didSet {
            guard let initialCoordinates = initialCoordinates else { return }
            let camera = GMSCameraPosition.camera(withLatitude: initialCoordinates.latitude, longitude: initialCoordinates.longitude, zoom: 12)
            mapView = GMSMapView.map(withFrame: view.frame, camera: camera)
            view.addSubview(mapView)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
//        drawRoute(routeName: BusRoutes.list.first ?? "")
        drawRoute(routeName: "10")
//        drawAllRoutes()
//        drawAllBusStops()
    }
    
    private func drawRoute(routeName: String) {
        if let url = Bundle.main.url(forResource: routeName, withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            if let gps = try? JSONDecoder().decode(GPS.self, from: data) {
                drawRoute(from: gps)
                drawBusStops(gps.busStops)
            }
        }
    }
    
    private func drawRoute(from gps: GPS) {
        let path = GMSMutablePath()
        gps.coordinates.enumerated().forEach { index, point in
            if let latitude = point.last, let longitude = point.first {
                if initialCoordinates == nil, index == 0 {
                    initialCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                }
                path.add(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            }
        }
        let polygon = GMSPolygon(path: path)
        polygon.fillColor = .clear
        polygon.strokeColor = .black
        polygon.strokeWidth = 2
        polygon.map = mapView
        
        gps.buses?.forEach { bus in
            let marker = GMSMarker()
            marker.icon = UIImage(named: "Arrow")
            marker.rotation = CLLocationDegrees(bus.c)
            marker.zIndex = 1000
            marker.position = CLLocationCoordinate2D(latitude: bus.lat, longitude: bus.lon)
            marker.title = bus.name
            marker.snippet = "Speed: \(bus.s) km/h"
            marker.map = mapView
        }
    }
    
    private func drawAllRoutes() {
        Bus.allRoutes.forEach { busRoute in
            drawRoute(routeName: busRoute)
        }
    }
    
    private func drawBusStops(_ busStops: [BusStop]) {
        busStops.forEach { busStop in
            if let latitide = busStop.location.first, let longitude = busStop.location.last {
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: latitide, longitude: longitude)
                marker.title = busStop.name
//                marker.snippet = busStop.stop_id
                marker.map = mapView
            }
        }
    }
    
    private func drawAllBusStops() {
        var busStops = Set<BusStop>()
        Bus.allRoutes.forEach { busRoute in
            if let url = Bundle.main.url(forResource: busRoute, withExtension: "json"),
               let data = try? Data(contentsOf: url) {
                if let gps = try? JSONDecoder().decode(GPS.self, from: data) {
                    gps.busStops.forEach { busStop in
                        busStops.insert(busStop)
                    }
                }
            }
        }
        drawBusStops(Array(busStops))
    }
}

