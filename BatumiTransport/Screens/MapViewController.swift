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
    private var markers = [String: GMSMarker]()

    var mapView: GMSMapView!
    private var initialCoordinates: CLLocationCoordinate2D? {
        didSet {
            guard let initialCoordinates = initialCoordinates else { return }
            let camera = GMSCameraPosition.camera(withLatitude: initialCoordinates.latitude, longitude: initialCoordinates.longitude, zoom: 14)
            mapView = GMSMapView.map(withFrame: view.frame, camera: camera)
            mapView.delegate = self
            view.addSubview(mapView)
        }
    }
    var currentRouteNumber: String? {
        didSet {
            if let currentRouteNumber = currentRouteNumber {
                mapView.clear()
                drawRoute(routeNumber: currentRouteNumber, isWithBusStops: true)
            }
        }
    }
    private var liveRouteTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataManager.shared.setup { [weak self] in
            
        }
        setupUI()
    }
    
    private func setupUI() {
//        drawRoute(routeName: BusRoutes.list.first ?? "")
//        drawRoute(routeNumber: "10")
//        drawAllRoutes(isWithBusStops: false)
        drawAllRoutes(isWithBusStops: false)
//        drawAllBusStops()
//        drawAllLiveRoutes()
    }
    
    // MARK: Map Drawing
    
    private func drawRoute(routeNumber: String, isWithBusStops: Bool) {
        if let url = Bundle.main.url(forResource: routeNumber, withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            if let busRoute = try? JSONDecoder().decode(BusRoute.self, from: data) {
                drawRoute(from: busRoute, isWithBusStops: isWithBusStops)
            }
        }
    }
    
    private func drawRoute(from busRoute: BusRoute, isWithBusStops: Bool) {
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
        polygon.strokeWidth = 2
        polygon.map = mapView
        
        if let buses = busRoute.buses {
//            var updatedIds = Set<String>()
            buses.forEach { bus in
                if let markerObject = markers.first(where: { $0.key == bus.id }) {
                    CATransaction.begin()
                    CATransaction.setAnimationDuration(2)
                    markerObject.value.position = CLLocationCoordinate2D(latitude: bus.lat, longitude: bus.lon)
                    markerObject.value.rotation = CLLocationDegrees(bus.c)
                    if let selectedMarker = mapView.selectedMarker, selectedMarker == markers[bus.id] {
                        mapView.animate(toLocation: markerObject.value.position)
                    }
//                    updatedIds.insert(bus.id)
                    CATransaction.commit()
                } else {
                    let marker = GMSMarker()
                    marker.rotation = CLLocationDegrees(bus.c)
                    marker.zIndex = 1000
                    marker.position = CLLocationCoordinate2D(latitude: bus.lat, longitude: bus.lon)
                    marker.icon = UIImage(named: "Arrow")
                    if let number = DataManager.shared.simpleBusRoutes.first(where: { $0.id == busRoute.routeId })?.number {
                        marker.title = number
                    }
                    marker.snippet = bus.name
//                    marker.snippet = "Speed: \(bus.s) km/h"
                    marker.map = mapView
                    markers[bus.id] = marker
                }
            }
        }
        
        if isWithBusStops {
            drawBusStops(busRoute.busStops)
        }
    }
    
    private func drawAllRoutes(isWithBusStops: Bool = false) {
        DataManager.shared.simpleBusRoutes.forEach { busRoute in
            drawRoute(routeNumber: busRoute.number, isWithBusStops: isWithBusStops)
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
                self?.drawLiveRoute(routeId: route.id)
            }
        }
    }
    
    func drawLiveRoute(routeId: String) {
        liveRouteTimer?.invalidate()
        liveRouteTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.getLiveBusRoute(with: routeId) { [weak self] busRoute, error in
                if var busRoute = busRoute {
                    busRoute.routeId = routeId
                    self?.drawRoute(from: busRoute, isWithBusStops: true)
                } else if let error = error {
                    print(error)
                }
            }
//            if let selectedMarker = self.mapView.selectedMarker,
//               let marker = self.markers.first(where: {$0.value == selectedMarker}) {
//                self.mapView.animate(toLocation: marker.value.position)
//            }
        }
        liveRouteTimer?.fire()
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

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.selectedMarker = marker
        let point = mapView.projection.point(for: marker.position)
        let camera = mapView.projection.coordinate(for: point)
        let position = GMSCameraUpdate.setTarget(camera)
        mapView.animate(with: position)
        return true
    }
}
