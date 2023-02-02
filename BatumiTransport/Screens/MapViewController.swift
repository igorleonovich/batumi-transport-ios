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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        if let url = Bundle.main.url(forResource: "13", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            if let gps = try? JSONDecoder().decode(GPS.self, from: data) {
                drawRoute(from: gps.coordinates)
                drawBusStops(gps.busStops)
            }
        }
    }
    
    private func drawRoute(from coordinates: [[Double]]) {
        let path = GMSMutablePath()
        coordinates.enumerated().forEach { index, point in
            if let latitude = point.first, let longitude = point.last {
                if index == 0 {
                    let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 14)
                    mapView = GMSMapView.map(withFrame: view.frame, camera: camera)
                    view.addSubview(mapView)
                }
                path.add(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            }
        }
        let polygon = GMSPolygon(path: path)
        polygon.fillColor = UIColor(red: 0.25, green: 0, blue: 0, alpha: 0.05);
        polygon.strokeColor = .black
        polygon.strokeWidth = 2
        polygon.map = mapView
    }
    
    private func drawBusStops(_ busStops: [BusStop]) {
        busStops.forEach { busStop in
            if let latitide = busStop.location.first, let longitude = busStop.location.last {
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: latitide, longitude: longitude)
                marker.title = busStop.name
                marker.snippet = busStop.stop_id
                marker.map = mapView
            }
        }
    }
}

