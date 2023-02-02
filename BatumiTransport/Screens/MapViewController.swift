//
//  MapViewController.swift
//  BatumiTransport
//
//  Created by Igor Leonovich on 2.02.23.
//

import GoogleMaps
import UIKit

final class MapViewController: UIViewController {
    
    private var routeDataTask: URLSessionTask?
    private lazy var sessionConfiguration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Content-Type": "application/x-www-form-urlencoded"]
        return config
    }()
    private var liveRoutes = [String: GPS]()

    private var mapView: GMSMapView!
    private var initialCoordinates: CLLocationCoordinate2D? {
        didSet {
            guard let initialCoordinates = initialCoordinates else { return }
            let camera = GMSCameraPosition.camera(withLatitude: initialCoordinates.latitude, longitude: initialCoordinates.longitude, zoom: 13)
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
//        drawRoute(routeName: "2")
        drawAllRoutes()
//        drawAllBusStops()
//        drawAllLiveRoutes()
    }
    
    // MARK: Map Drawing
    
    private func drawRoute(routeName: String) {
        if let url = Bundle.main.url(forResource: routeName, withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            if let gps = try? JSONDecoder().decode(GPS.self, from: data) {
                drawRoute(from: gps)
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
        polygon.strokeColor = .systemBlue
        polygon.strokeWidth = 3
        polygon.map = mapView
        
        gps.buses?.forEach { bus in
            let marker = GMSMarker()
            marker.rotation = CLLocationDegrees(bus.c)
            marker.zIndex = 1000
            marker.position = CLLocationCoordinate2D(latitude: bus.lat, longitude: bus.lon)
            marker.icon = UIImage(named: "Arrow")
            marker.title = bus.name
            marker.snippet = "Speed: \(bus.s) km/h"
            marker.map = mapView
        }
        drawBusStops(gps.busStops)
    }
    
    private func drawAllRoutes() {
        Bus.allRoutes.forEach { busRoute in
            drawRoute(routeName: busRoute)
        }
    }
    
    private func drawBusStops(_ busStops: [BusStop]) {
        busStops.enumerated().forEach { index, busStop in
            if let latitude = busStop.location.first, let longitude = busStop.location.last {
                if initialCoordinates == nil, index == 0 {
                    initialCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                }
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//                marker.icon = UIImage(named: "MapPin")
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
    
    // MARK: - Live
    
    private func drawAllLiveRoutes() {
        if let url = Bundle.main.url(forResource: "routes", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            if let routes = try? JSONDecoder().decode(Routes.self, from: data) {
                routes.routes.enumerated().forEach { index, route in
//                    guard index == 0 else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) - 0.5) { [weak self] in
                        self?.getRoute(with: route.id) { [weak self] gps, error in
                            if let gps = gps {
                                self?.drawRoute(from: gps)
                            } else if let error = error {
                                print(error)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Network
    
    func getRoute(with routeId: String, completion: @escaping (GPS?, Swift.Error?) -> Void) {
        routeDataTask?.cancel()
        
        let sessionDelegate = SessionDelegate()
        let session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: OperationQueue.main)
        
        guard let url = URL(string: "\(Constants.baseURL)/get-live-bus-stop-time?") else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let data = "routeId=\(routeId)".data(using: .utf8) {
            request.httpBody = data
            routeDataTask = session.dataTask(with: request) { [weak self] (data, response, error) in
                guard let self = self else { return }
                defer {
                    self.routeDataTask = nil
                }
                if let error = error {
                    completion(nil, error)
                } else if let data = data, let response = response as? HTTPURLResponse {
                    print(response.statusCode)
                    if response.statusCode == 200 {
                        let gps = try! JSONDecoder().decode(GPS.self, from: data)
                        completion(gps, nil)
                    } else if let error = error {
                        completion(nil, error)
                    }
                }
            }
            routeDataTask?.resume()
        }
    }
}

final class SessionDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        completionHandler(.useCredential, nil)
    }
}

struct Route: Codable {
    
    let number: String
    let id: String
}


struct Routes: Codable {
    
    let routes: [Route]
}
