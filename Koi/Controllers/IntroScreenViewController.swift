//
//  MainScreenViewController.swift
//  Koi
//
//  Created by john sanford on 8/24/19.
//  Copyright © 2019 Jack Sanford. All rights reserved.
//

import UIKit

class IntroScreenViewController: UIViewController {
    
    // Data passed from Instagram login process stored here
    var userHandle: String = "userHandle error!"
    var instaUID: String = "uid error!"
    var firebaseUID: String?

    @IBOutlet weak var testWelcome: UILabel!
    
    @IBAction func nextScreen(_ sender: UIButton) {
        // No need to do perform segue here because segue
        // is already connected to the button
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testWelcome.text = "Welcome \(userHandle)!!"
        testWelcome.lineBreakMode = .byWordWrapping
        testWelcome.numberOfLines = 0
    }
    
    let segueIdentifier = "ShowMainScreen"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Checks which segue was called
        var destination = segue.destination
        if let navcon = destination as? UINavigationController {
                destination = navcon.visibleViewController ?? navcon
            }
        if let mainVC = destination as? MainScreenViewController {
            mainVC.userHandle = userHandle
            mainVC.instaUID = instaUID
            mainVC.firebaseUID = firebaseUID
        }
    }
}
