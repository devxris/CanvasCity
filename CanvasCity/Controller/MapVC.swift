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
	
	// UI elements
	lazy var spinner: UIActivityIndicatorView = {
		let spinner = UIActivityIndicatorView()
		spinner.activityIndicatorViewStyle = .whiteLarge
		spinner.color = .darkGray
		return spinner
	}()
	lazy var progressLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont(name: "Avenir Next", size: 18)
		// label.text = "12/40 Photos Loaded"
		label.sizeToFit()
		label.textColor = .darkGray
		label.textAlignment = .center
		return label
	}()
	lazy var collectionView: UICollectionView = {
		let flowLayout = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
		collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "Cell")
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.backgroundColor = .white
		return collectionView
	}()
	
	var imageUrlString = [String]()
	var images = [UIImage]()
	
	func setupPullupView() { // based on UI heircharchy
		
		// add spinner
		spinner.center = CGPoint(x: (self.pullupView.frame.width - spinner.frame.width)/2,
		                         y: (self.pullupView.frame.height - spinner.frame.height)/2)
		collectionView.addSubview(spinner)
		spinner.startAnimating()
		
		// add progress label
		progressLabel.frame = CGRect(x: self.pullupView.frame.width / 2 - 100,
		                             y: self.pullupView.frame.height / 2 - 20 + 50, width: 200, height: 40)
		progressLabel.text = ""
		collectionView.addSubview(progressLabel)
		
		// add collection view
		pullupView.addSubview(collectionView)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		locationManager.delegate = self
		configureLocationServices()
		NotificationCenter.default.addObserver(self, selector: #selector(downloadProgress(notification:)), name: PHOTO_DOWNLOAD_COUNT, object: nil)
	}

	// target actions
	@IBAction func centerMap(_ sender: UIButton) {
		if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
			centerMapOnUserLocation()
		}
	}
	
	// helper functions
	func removePin() {
		mapView.annotations.forEach { mapView.removeAnnotation($0) }
		spinner.removeFromSuperview()
		progressLabel.removeFromSuperview()
		collectionView.removeFromSuperview()
	}
	
	func animateViewUp() {
		pullupViewHeightConstraint.constant = 300
		UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
		setupPullupView()
	}
	
	// selector functions
	@objc func animateViewDown() {
		FlickrService.instance.cancelAllSessions()
		spinner.removeFromSuperview()
		progressLabel.removeFromSuperview()
		collectionView.removeFromSuperview()
		pullupViewHeightConstraint.constant = 0
		UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
	}
	
	@objc func downloadProgress(notification: Notification) {
		guard let imagesCount = notification.userInfo?["imagesCount"] as? Int else { return }
		progressLabel.text = "\(imagesCount)/40 Photos Loaded"
	}

	@objc func dropPin(recognizer: UITapGestureRecognizer) {
		// remove previous annotation
		removePin()
		// animate pullup view
		animateViewUp()
		// cancel previous FlickrService sessions
		FlickrService.instance.cancelAllSessions()
		// remove all previous images
		images.removeAll()
		collectionView.reloadData()
		
		// get point from touch and covert to mapView coordinate
		let touchPoint = recognizer.location(in: mapView)
		let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
		// create annotation with customized MKAnnotation and add to mapView
		let annotation = DroppablePin(identifier: "droppablePin", coordinate: touchCoordinate)
		mapView.addAnnotation(annotation)
		// center to new annotation region
		let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2, regionRadius * 2)
		mapView.setRegion(coordinateRegion, animated: true)
		
		// get Flicker Photo URLs
		FlickrService.instance.retrieveURLs(forAnnotation: annotation) { (success, fetchedURLs) in
			self.imageUrlString.removeAll()
			if success { guard let photosURLs = fetchedURLs else { return }; print(photosURLs)
				// get Flicker Photos
				FlickrService.instance.retrieveImages(completion: { (finished, fetchedImages) in
					if finished {
						self.spinner.removeFromSuperview()
						self.progressLabel.removeFromSuperview()
						guard let images = fetchedImages else { return }
						DispatchQueue.main.async {
							self.images = images
							self.collectionView.reloadData()
						}
					}
				})
			}
		}
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

extension MapVC: UICollectionViewDataSource, UICollectionViewDelegate {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int { return 1}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return images.count
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCell
		let imageView = UIImageView(image: images[indexPath.item])
		cell.addSubview(imageView)
		return cell
	}
}
