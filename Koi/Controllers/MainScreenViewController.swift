//
//  MainScreenViewController.swift
//  Koi
//
//  Created by john sanford on 8/24/19.
//  Copyright © 2019 Jack Sanford. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class MainScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let ref = Database.database().reference()
    var userHandle: String?
    var instaUID: String?
    var firebaseUID: String?
    var matches: [String] = [] {
        didSet {
            print("Matches didSet and is \(matches)")
            listArray = sortList()
            tableView.reloadData()
        }
    }
    var listsUserIsOn: [String]? {
        didSet {
            print("listsUserIsOn gets set and is \(String(describing: listsUserIsOn))")
            checkForMatches(userList: listArray)
            tableView.reloadData()
        }
    }
    
    var listDict: [String: Bool]?

    var listArray: [String]? {
        didSet {
            print("listArray gets set!!!")
            // Clears out old listDict and populates with
            // new listArray values
            listDict = [:]
            if listArray != nil {
                for handle in listArray! {
                    listDict![handle] = true
                }
                // Updates list in the database
                let newListDict = listDict?.encode(dict: listDict)
                ref.child("users/\(firebaseUID!)/list").setValue(newListDict)
                
                // Sorts matches to front of listArray
                // Note: This does NOT call didSet on listArray again
                listArray = sortList()
                
                // Redisplays the table data
                tableView.reloadData()
            }
        }
    }
    
    @IBOutlet weak var listsUserIsOnText: UILabel!
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "LogOutSegue", sender: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserList()
        
        // This gets called when Koi app comes back into foreground
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification
            , object: nil)
        
        setupTableView()
    }
    
    @objc func appMovedToForeground() {
        loadUserList()
    }
    
    
    
    @IBAction func addCrush(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add Someone To Your List",
                                      message: "Type their Instagram handle",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Add",
                                       style: .default) { _ in
                                        guard let textField = alert.textFields?.first,
                                            let text = textField.text else { return }
                                        
                                        // adds the new crush to user's list
                                        // first checks that text field is not blank
                                        // and not equal to the user's handle
                                        if text.noAtSymbol() != self.userHandle?.noAtSymbol(), text != "" {
                                            self.listArray?.append(text.withAtSymbol())
                                        }
                                        
                                        // Checks how many lists user is on
                                        self.checkForNameOnLists(nonAtUserHandle: self.userHandle?.noAtSymbol()) { (lists) -> () in
                                            
                                            // resets listsUserIsOn
                                            self.listsUserIsOn = lists
                                            
                                            // changes text field in app
                                            self.listsUserIsOnText.text = "\(self.listsUserIsOn!.count)"
                                            
                                            // Now that we know new lists the user is on
                                            // check for any new matches
                                            self.checkForMatches(userList: self.listArray)
                                            self.tableView.reloadData()
                                            
                                            // Now that new matches have been checked for, sends notification for match or addition to list to added user
                                            self.sendPushNotification(to: text)
                                        }
                                        
        
    }
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    // Takes any optional userHandle (w/o the @ sign) and returns
    // an array of all the people who have this userHandle on their list
    // function uses a completion handler for async call
    func checkForNameOnLists(nonAtUserHandle: String?, completion: @escaping ([String]) -> ()) {
        var arrayOfUsersWhoHaveCurrentUserOnTheirList: [String] = []
        let userRef = self.ref.child("users")
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let listSnap = snap.childSnapshot(forPath: "list")
                let dict = listSnap.value as? [String : Bool]
                let atUserHandle = "@\(nonAtUserHandle!)"
                if dict?[atUserHandle] != nil {
                    if let userWithCurrentUserOnList = snap.childSnapshot(forPath: "userHandle").value as? String {
                        arrayOfUsersWhoHaveCurrentUserOnTheirList.append(userWithCurrentUserOnList)
                    }
                }
            }
            completion(arrayOfUsersWhoHaveCurrentUserOnTheirList)
        }
    }
    
    
    // Instantiates table view
    let tableView: UITableView = {
        
        let tv = UITableView()
        tv.backgroundColor = .deepBlue
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorColor = .deepBlue
        return tv
        
    }()
    
    func setupTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .deepBlue
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        tableView.register(MainScreenTableViewCell.self, forCellReuseIdentifier: "cellId")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 375),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor)
            ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // This logic is so we always have 1 table cell which will display a default message
        // to users who have no one on their list
        if listArray?.count == nil || listArray?.count == 0 {
            return 1
        } else {
            return listArray!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! MainScreenTableViewCell
        
        cell.backgroundColor = .deepBlue
        
        
        if listArray != nil {
            // If listArray count is 0 it will display default message
            if listArray!.count > 0 {
                let handle = listArray![indexPath.item]
                cell.listLabel.text = handle
                
                // Logic to decide if this cell is a match or not
                if matches.count > 0, matches.contains(handle) {
                    cell.listLabel.textColor = UIColor.black
                    cell.cellView.backgroundColor = .cyan
                } else {
                    cell.listLabel.textColor = .cyan
                    cell.cellView.backgroundColor = .deepBlue
                }
            } else {
                // Otherwise diplays the default message if list is empty
                cell.listLabel.text = "Use the + to add someone to your list"
                cell.listLabel.textColor = .cyan
                cell.cellView.backgroundColor = .deepBlue
            }
        }
        return cell
    }
    
    // Decides height of cells in the table
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    
    // For deleting rows in the table
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Removes this handle from user's list
            listArray?.remove(at: indexPath.item)
            
            // Checks how many lists user is on and updates matches
            // Do we need this after a handle is deleted from a list?
            self.checkForNameOnLists(nonAtUserHandle: self.userHandle) { (lists) -> () in
                self.listsUserIsOn = lists
                self.listsUserIsOnText.text = "\(self.listsUserIsOn!.count)"
                self.checkForMatches(userList: self.listArray)
                self.tableView.reloadData()
            }
        }
    }
    
    // Log Out segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueIdentifier = "LogOutSegue"
        if segue.identifier == segueIdentifier, segueIdentifier == "LogOutSegue" {
            var destination = segue.destination
            if let navcon = destination as? UINavigationController {
                destination = navcon.visibleViewController ?? navcon
            }
            if let phoneAuthVC = destination as? PhoneAuthViewController {
                phoneAuthVC.signedOut = true
            }
        }
    }
    
    // Function so matches go to top of user's list
    func sortList() -> [String] {
        if listArray != nil {
            // Creating a tempList so that listArray didSet is only called once
            var tempList = listArray!
            if matches.count > 0 {
                for handle in matches {
                    if let index = tempList.firstIndex(of: handle) {
                        let matchedHandle = tempList.remove(at: index)
                        tempList.insert(matchedHandle, at: 0)
                    }
                }
            }
            return tempList
        }
        return []
    }
    
    func checkForMatches(userList: [String]?) {
        if userList != nil, listsUserIsOn != nil {
            // Creating tempMatches so var's didSets don't get called
            var tempMatches: [String] = []
            for handle in userList! {
                let noAtHandle = handle.noAtSymbol()
                if listsUserIsOn!.contains(noAtHandle) {
                    tempMatches.append(handle)
                }
            }
            matches = tempMatches
        }
    }
    
    func sendPushNotification(to handle: String) {
        
        var pushToken: String?
        
        let handle = handle.noAtSymbol()
        
        let userRef = self.ref.child("users")
        
        // Grabbing the handle and pushToken for other user
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let handleSnap = snap.childSnapshot(forPath: "userHandle")
                let pushTokenSnap = snap.childSnapshot(forPath: "pushToken")
                let databaseHandle = handleSnap.value as? String
                if handle == databaseHandle {
                    pushToken = pushTokenSnap.value as? String
                }
            }
            // At this point the user had already added this other user to their list
            // Now we check if that "other user" has our user on their list
            // If so, we send "match" push notification, if not, other push notification
            if pushToken != nil {
                if self.listsUserIsOn != nil, self.listsUserIsOn!.contains(handle) {
                    let sender = PushNotificationSender()
                    sender.sendPushNotification(to: pushToken!, title: "You have a new match!", body: "You have a new match!")
                } else {
                    let sender = PushNotificationSender()
                    sender.sendPushNotification(to: pushToken!, title: "Someone added you to their list!", body: "Someone added you to their list!")
                }
            }
        }
    }
    
    func loadUserList() {
        
        // loads user's list
        ref.child("users/\(firebaseUID!)").observeSingleEvent(of: .value) { (snapshot) in
            if !snapshot.hasChild("list") {
                print("Starter list is assigned")
                // Assigns a starter list
                self.listArray = []
            } else {
                // retrieves list dictionary from Firebase
                let value = snapshot.value as? NSDictionary
                let codedListDict = value?["list"] as? [String : Bool]
                // Creates temporary dictionary to store decoded Firebase dictionary
                let tempListDict = codedListDict?.decode(dict: codedListDict)
                // Assigns the temp dictionary keys to be our listArray
                if tempListDict != nil {
                    self.listArray = Array(tempListDict!.keys)
                }
            }
            // Grabbing userHandle from Firebase
            if snapshot.hasChild("userHandle") {
                let value = snapshot.value as? NSDictionary
                if self.userHandle == nil {
                    self.userHandle = value?["userHandle"] as? String
                }
                
                // Checks how many lists user is on
                self.checkForNameOnLists(nonAtUserHandle: self.userHandle) { (lists) -> () in
                    self.listsUserIsOn = lists
                    self.listsUserIsOnText.text = "\(lists.count)"
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    
    
    
    
    
    
}

