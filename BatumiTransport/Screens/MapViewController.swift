//
//  MapViewController.swift
//  BatumiTransport
//
//  Created by Igor Leonovich on 2.02.23.
//

import GoogleMaps
import UIKit

class MapViewController: MainTabViewController {
    
    private var routeDataTask: URLSessionTask?
    private lazy var sessionConfiguration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Content-Type": "application/x-www-form-urlencoded"]
        return config
    }()
    private var liveRoutes = Set<BusRoute>()

    private var mapView: GMSMapView!
    private var initialCoordinates: CLLocationCoordinate2D? {
        didSet {
            guard let initialCoordinates = initialCoordinates else { return }
            let camera = GMSCameraPosition.camera(withLatitude: initialCoordinates.latitude, longitude: initialCoordinates.longitude, zoom: 13)
            mapView = GMSMapView.map(withFrame: view.frame, camera: camera)
            view.addSubview(mapView)
        }
    }
    
//    init() {
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataManager.shared.setup { [weak self] in
            
        }
        setupUI()
    }
    
    private func setupUI() {
//        drawRoute(routeName: BusRoutes.list.first ?? "")
//        drawRoute(routeNumber: "10")
//        drawAllRoutes()
//        drawAllBusStops()
        drawAllLiveRoutes()
    }
    
    // MARK: Map Drawing
    
    private func drawRoute(routeNumber: String) {
        if let url = Bundle.main.url(forResource: routeNumber, withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            if let busRoute = try? JSONDecoder().decode(BusRoute.self, from: data) {
                drawRoute(from: busRoute)
            }
        }
    }
    
    private func drawRoute(from busRoute: BusRoute) {
        let path = GMSMutablePath()
        busRoute.coordinates.enumerated().forEach { index, point in
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
        
        busRoute.buses?.forEach { bus in
            let marker = GMSMarker()
            marker.rotation = CLLocationDegrees(bus.c)
            marker.zIndex = 1000
            marker.position = CLLocationCoordinate2D(latitude: bus.lat, longitude: bus.lon)
            marker.icon = UIImage(named: "Arrow")
            marker.title = bus.name
            marker.snippet = "Speed: \(bus.s) km/h\nid: \(bus.id)"
            marker.map = mapView
//            if let latitude = busRoute.coordinates.last?.last, let longitude = busRoute.coordinates.last?.first {
//                CATransaction.begin()
//                CATransaction.setAnimationDuration(150)
//                marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//                CATransaction.commit()
//            }
        }
        drawBusStops(busRoute.busStops)
    }
    
    private func drawAllRoutes() {
        DataManager.shared.simpleBusRoutes.forEach { busRoute in
            drawRoute(routeNumber: busRoute.number)
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
                var description = ""
                busStop.output.forEach { output in
                    description += output.value
                }
                marker.snippet = description
                marker.map = mapView
            }
        }
    }
    
    private func drawAllBusStops() {
        var busStops = Set<BusStop>()
        DataManager.shared.simpleBusRoutes.forEach { busRoute in
            if let url = Bundle.main.url(forResource: busRoute.number, withExtension: "json"),
               let data = try? Data(contentsOf: url) {
                if let busRoute = try? JSONDecoder().decode(BusRoute.self, from: data) {
                    busRoute.busStops.forEach { busStop in
                        busStops.insert(busStop)
                    }
                }
            }
        }
        drawBusStops(Array(busStops))
    }
    
    // MARK: - Live
    
    private func drawAllLiveRoutes() {
        DataManager.shared.simpleBusRoutes.enumerated().forEach { index, route in
//                    guard index == 0 else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) - 0.5) { [weak self] in
                self?.getLiveBusRoute(with: route.id) { [weak self] busRoute, error in
                    if var busRoute = busRoute {
                        busRoute.routeId = route.id
                        self?.drawRoute(from: busRoute)
                    } else if let error = error {
                        print(error)
                    }
                }
            }
        }
    }
    
    // MARK: Network
    
    func getLiveBusRoute(with routeId: String, completion: @escaping (BusRoute?, Swift.Error?) -> Void) {
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
                        let busRoute = try! JSONDecoder().decode(BusRoute.self, from: data)
                        self.liveRoutes.insert(busRoute)
                        completion(busRoute, nil)
                    } else if let error = error {
                        completion(nil, error)
                    }
                }
            }
            routeDataTask?.resume()
        }
    }
}
