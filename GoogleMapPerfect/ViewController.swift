//
//  ViewController.swift
//  GoogleMapPerfect
//
//  Created by Duc Anh on 12/20/18.
//  Copyright © 2018 Duc Anh. All rights reserved.
//

import UIKit
import  GoogleMaps
import GooglePlaces
class ViewController: UIViewController, GMSMapViewDelegate {
    
    var locationManager = CLLocationManager()
    var infoMarker = GMSMarker()
    
    @IBOutlet weak var mapVIew: GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        showLocationManager()
        mapVIew.settings.myLocationButton = true
        mapVIew.settings.compassButton = true
        mapVIew.isMyLocationEnabled = true
        mapVIew.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func showLocationManager() {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
    }

    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 15.0)
        mapView.animate(to: camera)
        infoMarker.snippet = placeID
        infoMarker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        infoMarker.icon = GMSMarker.markerImage(with: #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1))
        infoMarker.isFlat = true
        infoMarker.title = name
        infoMarker.opacity = 0
        infoMarker.infoWindowAnchor.y = 1
        infoMarker.map = mapView
        mapView.selectedMarker = infoMarker
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastCamera = locations.last else {return}
        let camera = GMSCameraPosition.camera(withTarget: lastCamera.coordinate, zoom: 15.0)
        mapVIew.camera = camera
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .restricted, .denied, .authorizedWhenInUse:
            showAlertToOpenSetting(title: "yeu cau truy cap", message: "ban hay cap phep")
        case .authorizedAlways:
            break
        }
    }
    
}
