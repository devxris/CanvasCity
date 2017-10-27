//
//  DroppablePin.swift
//  CanvasCity
//
//  Created by Chris Huang on 27/10/2017.
//  Copyright © 2017 Chris Huang. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation {
	
	var identifier: String
	var coordinate: CLLocationCoordinate2D
	
	init(identifier: String ,coordinate: CLLocationCoordinate2D) {
		self.identifier = identifier
		self.coordinate = coordinate
	}
}
