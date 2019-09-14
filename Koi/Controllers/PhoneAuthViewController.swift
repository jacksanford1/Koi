//
//  PhoneAuthViewController.swift
//  Koi
//
//  Created by john sanford on 8/27/19.
//  Copyright © 2019 Jack Sanford. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import FirebaseAuth

class PhoneAuthViewController: UIViewController, FUIAuthDelegate {
    
    let fullLogin = false
    var signedOut = false
    var newUser: Bool?
    fileprivate(set) var auth:Auth?
    fileprivate(set) var authUI: FUIAuth? //only set internally but get externally
    fileprivate(set) var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    var segueIdentifier: String? {
        didSet {
            chooseNextVC()
        }
    }
    var firebaseUID: String? {
        didSet {
            API.FIREBASE_UUID = firebaseUID!
            let pushManager = PushNotificationManager(userID: API.FIREBASE_UUID)
            pushManager.registerForPushNotifications()
        }
    }
    var userPhoneNumber: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor.deepBlue
        print("viewWillAppear gets called!")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
                
        // logs user out
        if fullLogin || signedOut {
            do {
                try Auth.auth().signOut()
            }
            catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        self.auth = Auth.auth()
        self.authUI = FUIAuth.defaultAuthUI()
        self.authUI?.delegate = self
        self.authUI?.providers = [FUIPhoneAuth(authUI: self.authUI!),]
        
        // initializes listener auth state changes (login, etc.)
        self.authStateListenerHandle = self.auth?.addStateDidChangeListener { (auth, user) in
            // if user is nil, do login Action
            guard user != nil else {
                self.loginAction(sender: self)
                return
            }
            // Start accessing the realtime database
            let ref = Database.database().reference()
            
            // check for values
            ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if snapshot.hasChild(user!.uid) {
                    
                    // This user already exists in database, don't show them intro screen
                    print("Not a new user, skip to home page")
                    self.firebaseUID = user!.uid
                    let rawUserPhoneNumber = user!.providerData[0].phoneNumber
                    if rawUserPhoneNumber != nil {
                        self.userPhoneNumber = rawUserPhoneNumber!.tenChars()
                    }
                    self.newUser = false
                    self.segueIdentifier = "SkipToMainScreen"

                } else {
                    
                    // This is a new user, show them intro screen
                    print("Created a new user! Take them to intro screen")
                    ref.child("users/\(user!.uid)/phoneAuthID").setValue(user!.uid)
                    let rawUserPhoneNumber = user!.providerData[0].phoneNumber
                    if rawUserPhoneNumber != nil {
                        self.userPhoneNumber = rawUserPhoneNumber!.tenChars()
                    }
                    ref.child("users/\(user!.uid)/userPhoneNumber").setValue(self.userPhoneNumber)
                    self.firebaseUID = user!.uid
                    self.newUser = true
                    self.segueIdentifier = "ShowIntroScreen"

                }
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ViewDidAppear gets called!")
    
        chooseNextVC()
        
    }

    func chooseNextVC() {
        if newUser != nil, newUser == true {
            print("Seguing to intro screen")
            performSegue(withIdentifier: "ShowIntroScreen", sender: nil)
        } else if newUser != nil, newUser == false {
            print("Did not segue to intro screen")
            performSegue(withIdentifier: "SkipToMainScreen", sender: nil)
        } else {
            print("Skipped segue")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == segueIdentifier, segueIdentifier == "ShowIntroScreen" {
            var destination = segue.destination
            if let navcon = destination as? UINavigationController {
                destination = navcon.visibleViewController ?? navcon
            }
            if let introVC = destination as? IntroScreenViewController {
                introVC.firebaseUID = firebaseUID
                introVC.userPhoneNumber = userPhoneNumber
            }
        } else if segue.identifier == segueIdentifier, segueIdentifier == "SkipToMainScreen" {
            var destination = segue.destination
            if let navcon = destination as? UINavigationController {
                destination = navcon.visibleViewController ?? navcon
            }
            if let mainVC = destination as? MainScreenViewController {
                mainVC.firebaseUID = firebaseUID
                mainVC.userPhoneNumber = userPhoneNumber
            }
        }
    }
}

extension PhoneAuthViewController {
    
    @IBAction func loginAction(sender: AnyObject) {
        // Present the default login view controller provided by authUI
        let authViewController = authUI?.authViewController();
        authViewController?.navigationBar.isTranslucent = false
        authViewController?.navigationBar.barTintColor = UIColor.deepBlue
        authViewController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.cyan]
        self.present(authViewController!, animated: false, completion: nil)
        
    }
    
    // Implement the required protocol method for FIRAuthUIDelegate
    // Right now this method is not getting called for some reason
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        
        guard let authError = error else { return }
        
        let errorCode = UInt((authError as NSError).code)
        
        switch errorCode {
        case FUIAuthErrorCode.userCancelledSignIn.rawValue:
            print("User cancelled sign-in");
            break
            
        default:
            let detailedError = (authError as NSError).userInfo[NSUnderlyingErrorKey] ?? authError
            print("Login error: \((detailedError as! NSError).localizedDescription)");
        }
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        
        // Create an instance of the Firebase Auth login view controller
        let loginViewController = FUIAuthPickerViewController(authUI: authUI)
        
        // Set background color to orange
        loginViewController.view.subviews[0].backgroundColor = UIColor.deepBlue
        loginViewController.view.subviews[0].subviews[0].backgroundColor = UIColor.deepBlue
        loginViewController.extendedLayoutIncludesOpaqueBars = true
        loginViewController.navigationItem.leftBarButtonItem = nil
        loginViewController.navigationItem.title = "koi"

        
        // Create a frame for an ImageView to hold our logo
        let marginInsets: CGFloat = 16
        let imageHeight: CGFloat = 225
        let imageY = self.view.center.y - imageHeight
        let logoFrame = CGRect(x: self.view.frame.origin.x + marginInsets, y: imageY, width: self.view.frame.width - (marginInsets*2), height: imageHeight)
        
        // Create the UIImageView using the frame created above and add the image
        let logoImageView = UIImageView(frame: logoFrame)
        logoImageView.image = UIImage(named: "clearKois")
        logoImageView.contentMode = .scaleAspectFill
        loginViewController.view.addSubview(logoImageView)
        
        return loginViewController
    }
    
}
    

    

