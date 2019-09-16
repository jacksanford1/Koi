//
//  MainScreenViewController.swift
//  Koi
//
//  Created by john sanford on 8/24/19.
//  Copyright © 2019 Jack Sanford. All rights reserved.
//

import UIKit

class IntroScreenViewController: UIViewController {
    
    var firebaseUID: String?
    var userPhoneNumber: String?
    @IBOutlet weak var contentView: UIView!
    
    let dataSource = ["View Controller 1", "View Controller 2", "View Controller 3", "View Controller 4", "Go To Main Screen"]
    
    var currentViewControllerIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePageViewController()
    }
    
    func configurePageViewController() {
        
        guard let pageViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: CustomPageViewController.self)) as? CustomPageViewController else {
            return
        }
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        pageViewController.view.backgroundColor = UIColor.deepBlue
        
        contentView.addSubview(pageViewController.view)
        
        let views: [String: UIView] = ["pageView": pageViewController.view]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[pageView]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[pageView]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views))
        
        guard let startingViewController = detailViewControllerAt(index: currentViewControllerIndex) else {
            return
        }
        
        pageViewController.setViewControllers([startingViewController], direction: .forward, animated: true)
        
    }
    
    func detailViewControllerAt(index: Int) -> DataViewController? {
        
        print("index is \(index)")
        
        if index > dataSource.count || dataSource.count == 0 {
            print("This stopper function gets called")
            return nil
        }
        
        if index == 5 {
            print("Made it through index == 5")
            if firebaseUID != nil, userPhoneNumber != nil {
                print("Made it through firebaseUID and userPhoneNumber not nil")
                performSegue(withIdentifier: "ShowMainScreen", sender: nil)
            }
        }
        
        guard let dataViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: DataViewController.self)) as? DataViewController else {
            return nil
        }
        
        dataViewController.firebaseUID = firebaseUID
        dataViewController.userPhoneNumber = userPhoneNumber
        dataViewController.index = index
        
        return dataViewController
    }
    
}

extension IntroScreenViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentViewControllerIndex
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return dataSource.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let dataViewController = viewController as? DataViewController
        
        guard var currentIndex = dataViewController?.index else {
            return nil
        }
        
        currentViewControllerIndex = currentIndex
        
        if currentIndex == 0 {
            return nil
        }
        
        currentIndex -= 1
        
        return detailViewControllerAt(index: currentIndex)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let dataViewController = viewController as? DataViewController
        
        guard var currentIndex = dataViewController?.index else {
            return nil
        }
        
        if currentIndex == dataSource.count {
            return nil
        }
        
        currentIndex += 1
        
        currentViewControllerIndex = currentIndex
        
        return detailViewControllerAt(index: currentIndex)
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Prepare for segue gets called!")
        if segue.identifier == "ShowMainScreen", firebaseUID != nil, userPhoneNumber != nil {
            var destination = segue.destination
            if let navcon = destination as? UINavigationController {
                destination = navcon.visibleViewController ?? navcon
            }
            if let mainVC = destination as? MainScreenViewController {
                print("firebaseUID gets set in prepareforsegue")
                mainVC.firebaseUID = firebaseUID
                mainVC.userPhoneNumber = userPhoneNumber
            }
        }
    }
    
}
    
    
    
    
    
//    var userPhoneNumber: String?
//    var firebaseUID: String?
//
//    @IBOutlet weak var testWelcome: UILabel!
//
//    @IBAction func nextScreen(_ sender: UIButton) {
//        // No need to do perform segue here because segue
//        // is already connected to the button
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        testWelcome.text = "Welcome \(userPhoneNumber ?? "Error")!!"
//        testWelcome.lineBreakMode = .byWordWrapping
//        testWelcome.numberOfLines = 0
//    }
//
//    let segueIdentifier = "ShowMainScreen"
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        // Checks which segue was called
//        var destination = segue.destination
//        if let navcon = destination as? UINavigationController {
//                destination = navcon.visibleViewController ?? navcon
//            }
//        if let mainVC = destination as? MainScreenViewController, userPhoneNumber != nil, firebaseUID != nil {
//            mainVC.userPhoneNumber = userPhoneNumber
//            mainVC.firebaseUID = firebaseUID
//        }
//    }
//}
