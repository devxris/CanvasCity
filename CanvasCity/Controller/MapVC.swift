//
//  MapVC.swift
//  CanvasCity
//
//  Created by Chris Huang on 27/10/2017.
//  Copyright © 2017 Chris Huang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController, UIGestureRecognizerDelegate {

	// outlets
	@IBOutlet weak var mapView: MKMapView! {
		didSet {
			mapView.delegate = self
			// add double tap gesture
			let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(recognizer:)))
			doubleTap.numberOfTapsRequired = 2
			doubleTap.delegate = self
			mapView.addGestureRecognizer(doubleTap)
		}
	}
	
	// variables
	let locationManager = CLLocationManager()
	let authorizationStatus = CLLocationManager.authorizationStatus()
	let regionRadius: Double = 1000
	
	override func viewDidLoad() {
		super.viewDidLoad()
		locationManager.delegate = self
		configureLocationServices()
	}

	// target actions
	@IBAction func centerMap(_ sender: UIButton) {
		if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
			centerMapOnUserLocation()
		}
	}
	
	// helper functions
	func removePin() { mapView.annotations.forEach { mapView.removeAnnotation($0) } }
	
	// selector functions
	@objc func dropPin(recognizer: UITapGestureRecognizer) {
		// remove previous annotation
		removePin()
		// get point from touch and covert to mapView coordinate
		let touchPoint = recognizer.location(in: mapView)
		let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
		// create annotation with customized MKAnnotation and add to mapView
		let annotation = DroppablePin(identifier: "droppablePin", coordinate: touchCoordinate)
		mapView.addAnnotation(annotation)
		// center to new annotation region
		let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2, regionRadius * 2)
		mapView.setRegion(coordinateRegion, animated: true)
	}
}

extension MapVC: MKMapViewDelegate {
	
	// customized function
	func centerMapOnUserLocation() {
		guard let coordinate = locationManager.location?.coordinate else { return } // get user current location
		let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2, regionRadius * 2)
		mapView.setRegion(coordinateRegion, animated: true)
	}
	
	// MKMapViewDelegate functions
}

extension MapVC: CLLocationManagerDelegate {
	
	// customized function
	func configureLocationServices() {
		if authorizationStatus == .notDetermined {
			locationManager.requestAlwaysAuthorization()
		} else {
			return
		}
	}
	
	// CLLocationManagerDelegate functions
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		centerMapOnUserLocation()
	}
}
