//
//  MapVC.swift
//  CanvasCity
//
//  Created by Chris Huang on 27/10/2017.
//  Copyright © 2017 Chris Huang. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {

	// outlets
	@IBOutlet weak var mapView: MKMapView! {
		didSet {
			mapView.delegate = self
		}
	}
	

	// target actions
	@IBAction func centerMap(_ sender: UIButton) {
	}
	
}

extension MapVC: MKMapViewDelegate {
	
}

