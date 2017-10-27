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
	@IBOutlet weak var pullupView: UIView! {
		didSet {
			// add swipe down pullupView
			let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
			swipeDown.direction = .down
			pullupView.addGestureRecognizer(swipeDown)
		}
	}
	@IBOutlet weak var pullupViewHeightConstraint: NSLayoutConstraint!
	
	// variables
	let locationManager = CLLocationManager()
	let authorizationStatus = CLLocationManager.authorizationStatus()
	let regionRadius: Double = 1000
	
	lazy var spinner: UIActivityIndicatorView = {
		let spinner = UIActivityIndicatorView()
		spinner.center = CGPoint(x: (self.pullupView.frame.width - spinner.frame.width)/2,
		                          y: (self.pullupView.frame.height - spinner.frame.height)/2)
		spinner.activityIndicatorViewStyle = .whiteLarge
		spinner.color = .darkGray
		spinner.startAnimating()
		return spinner
	}()
	
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
	func animateViewUp() {
		pullupViewHeightConstraint.constant = 300
		UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
		pullupView.addSubview(spinner)
	}
	
	// selector functions
	@objc func animateViewDown () {
		pullupViewHeightConstraint.constant = 0
		UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
	}

	@objc func dropPin(recognizer: UITapGestureRecognizer) {
		// remove previous annotation
		removePin()
		// animate pullup view
		animateViewUp()
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
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if annotation is MKUserLocation { return nil } // prevent user location overriding 
		let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
		pinAnnotation.pinTintColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
		pinAnnotation.animatesDrop = true
		return pinAnnotation
	}
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
