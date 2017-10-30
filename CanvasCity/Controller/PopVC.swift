//
//  PopVC.swift
//  CanvasCity
//
//  Created by Chris Huang on 30/10/2017.
//  Copyright © 2017 Chris Huang. All rights reserved.
//

import UIKit

class PopVC: UIViewController {

	// outlets
	@IBOutlet weak var imageView: UIImageView!
	
	// variables
	var passedImage: UIImage!
	
	// helper function
	func initData(forImage image: UIImage) { self.passedImage = image }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		imageView.image = passedImage
		
		let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapDismiss))
		doubleTap.numberOfTapsRequired = 2
		view.addGestureRecognizer(doubleTap)
	}
	
	// selector function
	@objc func doubleTapDismiss() { dismiss(animated: true, completion: nil) }
}
