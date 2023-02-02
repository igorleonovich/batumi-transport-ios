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
        if let url = Bundle.main.url(forResource: "1", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            if let gps = try? JSONDecoder().decode(GPS.self, from: data) {
                let path = GMSMutablePath()
                gps.coordinates.enumerated().forEach { index, point in
                    if let latitude = point.first, let longitude = point.last {
                        if index == 0 {
                            let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 14)
                            mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
                            self.view.addSubview(mapView)

                            let marker = GMSMarker()
                            marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                            marker.title = "City Name"
                            marker.snippet = "Country Name"
                            marker.map = mapView
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
        }
    }
}

