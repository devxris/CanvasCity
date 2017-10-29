//
//  FlickrURL.swift
//  CanvasCity
//
//  Created by Chris Huang on 28/10/2017.
//  Copyright © 2017 Chris Huang. All rights reserved.
//

import Foundation

struct FlickrPhotoURL: Decodable {
	
	struct Photo: Decodable {
		var farm: Int
		var id: String
		var isfamily: Int
		var ispublic: Int
		var owner: String
		var secret: String
		var server: String
		var title: String
	}
	
	struct Photos: Decodable {
		var page: Int
		var pages: Int
		var perpage: Int
		var photo: [Photo]
		var total: String
	}
	
	var photos: Photos
	var stat: String
}
