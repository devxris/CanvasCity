//
//  FlickrService.swift
//  CanvasCity
//
//  Created by Chris Huang on 28/10/2017.
//  Copyright © 2017 Chris Huang. All rights reserved.
//

import Foundation
import Alamofire

// photo search API URL: https://www.flickr.com/services/api/explore/flickr.photos.search
// reference url: https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=c032766f0c46ea5711f482ace878c21a&lat=42.8&lon=122.8&radius=1&radius_units=mi&per_page=40&format=json&nojsoncallback=1

let API_KEY = "832d481d563eae0a4471d7872be655c3"
func flickrURL(forAPIKey key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
	return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
}

class FlickrService {
	
	static let instance = FlickrService()
	
	var url: FlickrPhotoURL?
	var photosUrls = [String]()
	
	func retrieveURLs(forAnnotation annotation: DroppablePin, completion: @escaping (_ status: Bool, _ urls: [String]?) -> Void) {
		
		Alamofire.request(flickrURL(forAPIKey: API_KEY, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
			if response.result.error == nil {
				guard let data = response.data else { return }
				do {
					self.url = try JSONDecoder().decode(FlickrPhotoURL.self, from: data)
					guard let photos = self.url?.photos.photo else { return }
					photos.forEach {
						let postURL = "https://farm\($0.farm).staticflickr.com/\($0.server)/\($0.id)_\($0.secret)_h_d.jpg"
						self.photosUrls.append(postURL)
					}
				} catch let error { print(error.localizedDescription) }
				completion(true, self.photosUrls)
			} else {
				completion(false, nil)
			}
		}
	}
}
