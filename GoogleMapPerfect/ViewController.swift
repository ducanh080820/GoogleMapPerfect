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
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}

class ViewController: UIViewController, GMSMapViewDelegate {
    
    var locationManager = CLLocationManager()
    var infoMarker = GMSMarker()
    var resultSearchController: UISearchController? = nil
    var selectedPin: MKPlacemark? = nil
    var mapView: GMSMapView?
    
    
    @IBOutlet weak var mapVIew: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        showLocationManager()
//        mapVIew.settings.myLocationButton = true
//        mapVIew.settings.compassButton = true
//        mapVIew.isMyLocationEnabled = true
//        mapVIew.delegate = self
        
        let locationSearchTable = storyboard?.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        locationSearchTable.mapView = mapVIew
        locationSearchTable.handleMapSearchDelegate = self
        //this cofigures the search bar, and embeds it within the navigation bar
        let searchBar = resultSearchController?.searchBar
        searchBar?.sizeToFit()
        searchBar?.placeholder = "search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        mapView?.settings.myLocationButton = true
        mapView?.isMyLocationEnabled = true
        mapVIew.delegate = self
        definesPresentationContext = true
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func getDirections() {
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let lauchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: lauchOptions)
        }
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
        mapView?.camera = camera
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

extension ViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
        //cache the pin
        selectedPin = placemark
        //clear existing pins
        mapVIew?.removeAnnotations(mapVIew.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapVIew?.addAnnotation(annotation)
        let span = MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion.init(center: placemark.coordinate, span: span)
        mapVIew?.setRegion(region, animated: true)
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
        pinView?.pinTintColor = UIColor.red
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), for: .normal)
        button.addTarget(self, action: #selector(getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
}

