//
//  ViewController.swift
//  Koi
//
//  Created by john sanford on 8/23/19.
//  Copyright © 2019 Jack Sanford. All rights reserved.
//

//import UIKit
//import WebKit
//import Firebase
//
//class InstaLoginViewController: UIViewController, WKNavigationDelegate {
//    
//    var webView: WKWebView!
//    
//    // Stores data we request from Instagram user data
//    // for passing to next view controller in prepare method
//    var userHandle: String?
//    var instaUID: String?
//    var firebaseUID: String?
//    var userPhoneNumber: String?
//    
//    override func loadView() {
//        super.loadView()
//        
//        webView = WKWebView()
//        webView.navigationDelegate = self
//        
//        // Sets this View Controller's view to the Webview
//        view = webView
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Builds the Instagram Authentication URL
//        let authURL = String(format: "%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@&DEBUG=True", arguments: [API.INSTAGRAM_AUTHURL,API.INSTAGRAM_CLIENT_ID,API.INSTAGRAM_REDIRECT_URI, API.INSTAGRAM_SCOPE])
//        let urlRequest = URLRequest.init(url: URL.init(string: authURL)!)
//        
//        // Loads the URL
//        webView.load(urlRequest)
//        
//        // Builds the refresh button for the web browser view
//        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
//        toolbarItems = [refresh]
//        navigationController?.isToolbarHidden = false
//    }
//    
//    // Sets nav bar title?
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        title = webView.title
//    }
//    
//    // Checks for the redirect URL
//    func checkRequestForCallBackURL(request: URLRequest) -> Bool {
//        let requestURLString = (request.url?.absoluteString)! as String
//        if requestURLString.hasPrefix(API.INSTAGRAM_REDIRECT_URI) {
//            
//            // Gets the access token out of the redirect URL
//            let range: Range<String.Index> = requestURLString.range(of: "#access_token=")!
//            
//            // Sends user's auth token to handleAuth method
//            handleAuth(authToken: String(requestURLString[range.upperBound...]))
//            return false
//        }
//        return true
//    }
//    
//    func handleAuth(authToken: String) {
//        
//        // Sets access token constant
//        API.INSTAGRAM_ACCESS_TOKEN = authToken
//        print("Instagram auth token == \(authToken)")
//        
//        // Executes method to fetch user's info (see method below)
//        // then segues to our app's first screen
//        getUserInfo() { (data) in
//            DispatchQueue.main.async {
//                self.performSegue(withIdentifier: "ShowIntroScreen", sender: nil)
//            }
//        }
//    }
//    
//    // Builds url to request user's data, retrieves data
//    // then grabs whatever we want from the user data json response
//    func getUserInfo(completion: @escaping ((_ data: Bool) -> Void)) {
//        
//        let url = String(format: "%@%@", arguments: [API.INSTAGRAM_USER_INFOURL, API.INSTAGRAM_ACCESS_TOKEN])
//        var request = URLRequest(url: URL(string: url)!)
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        let session = URLSession.shared
//        let task = session.dataTask(with: request) { (data, response, error) -> Void in
//            guard error == nil else {
//                completion(false)
//                // Failure
//                return
//            }
//            // Make sure we got data
//            guard let responseData = data else {
//                completion(false)
//                // Error: did not receive data
//                return
//            }
//            do {
//                guard let dataResponse = try JSONSerialization.jsonObject(with: responseData, options: [])
//                    as? [String : AnyObject] else {
//                        completion(false)
//                        // Error: did not receive data
//                        return
//                }
//                completion(true)
//                // Success: dataResponse contains the Instagram data
//                if let dataResponseObject = dataResponse["data"] as? [String:AnyObject] {
//                    self.userHandle = dataResponseObject["username"] as! String?
//                    self.instaUID = dataResponseObject["id"] as! String?
//                }
//                
//                // add handle and instaUID to database
//                let ref = Database.database().reference()
//                ref.child("users/\(self.firebaseUID!)/userHandle").setValue(self.userHandle)
//                ref.child("users/\(self.firebaseUID!)/instaUID").setValue(self.instaUID)
//
//            } catch let err {
//                completion(false)
//                // Failure
//                print("Error code: \(err)")
//            }
//        }
//        task.resume()
//    }
//    
//    
//     // MARK: - Prepare for Segue
//    
//    let segueIdentifier = "ShowIntroScreen"
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//        // Checks which segue was called
//        if segue.identifier == segueIdentifier {
//            // Checks which segue was called
//            var destination = segue.destination
//            if let navcon = destination as? UINavigationController {
//                destination = navcon.visibleViewController ?? navcon
//            }
//            if let mainVC = destination as? IntroScreenViewController, firebaseUID != nil, userHandle != nil, instaUID != nil {
//                mainVC.userHandle = userHandle!
//                mainVC.instaUID = instaUID!
//                mainVC.firebaseUID = firebaseUID
//            } else {
//                print("Failed to segue, firebaseUID is \(String(describing: firebaseUID))")
//            }
//        }
//    }
//}
//
//extension InstaLoginViewController {
//    
//    // Allows navigation to redirect URL if a redirect URL exists
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
//        
//        if checkRequestForCallBackURL(request: navigationAction.request) {
//            decisionHandler(.allow)
//        } else {
//            decisionHandler(.cancel)
//        }
//    }
//}

