//
//  DataViewController.swift
//  Koi
//
//  Created by john sanford on 9/13/19.
//  Copyright © 2019 Jack Sanford. All rights reserved.
//

import UIKit

class DataViewController: UIViewController {

    @IBOutlet weak var displayLabel: UILabel!
    
    var firebaseUID: String?
    var userPhoneNumber: String?
    var index: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var backgroundImage: UIImage?
        
        if index != nil {
            switch index {
            case 0 : backgroundImage = UIImage.init(named: "Create a List")
            case 1 : backgroundImage = UIImage.init(named: "Matches")
            case 2 : backgroundImage = UIImage.init(named: "Social Score")
            default: break
            }
        }
        
        let backgroundImageViewFrame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - 20)
        let backgroundImageView = UIImageView.init(frame: backgroundImageViewFrame)
        
        if let selectedBackgroundImage = backgroundImage {
            backgroundImageView.image = selectedBackgroundImage
            backgroundImageView.contentMode = .scaleToFill
            backgroundImageView.alpha = 1.0
            
            self.view.insertSubview(backgroundImageView, at: 0)
        }
    }
    

}
