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
import ContactsUI

class MainScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CNContactPickerDelegate {
    
    let ref = Database.database().reference()
    var userPhoneNumber: String?
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
    
    var listDict: [String: String]? {
        didSet {
            print("listDict gets set and is \(String(describing: listDict))")
            
            // Clears out old listArray and populates with
            // new listArray values
            listArray = []
            if listDict != nil {
                for (key, _) in listDict! {
                    listArray!.append(key)
                }
                // Updates list in the database
                let newListDict = listDict!.encode(dict: listDict)
                ref.child("users/\(firebaseUID!)/list").setValue(newListDict)
                
                // Sorts matches to front of listArray
                // Note: This does NOT call didSet on listArray again
                listArray = sortList()
                
                // Redisplays the table data
                tableView.reloadData()
            }
        }
    }

    var listArray: [String]? {
        didSet {
            print("listArray did set and is \(String(describing: listArray))")
        }
    }
    
    @IBOutlet weak var listsUserIsOnText: UILabel!
    
    @IBAction func actionSheet(_ sender: UIBarButtonItem) {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let alert = UIAlertController(title: "Koi\nkoidating.com\nv\(appVersion ?? "2.0")", message: "", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Contact Us", style: .default , handler:{ (UIAlertAction)in
            if let url = URL(string: "https://www.koidating.com/contact") {
                UIApplication.shared.open(url, options: [:])
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive , handler:{ (UIAlertAction)in
                self.performSegue(withIdentifier: "LogOutSegue", sender: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
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
        print("appMovedToForeground")
        loadUserList()
    }
    
    @IBAction func addCrush(_ sender: UIBarButtonItem) {
        let contactVC = CNContactPickerViewController()
        contactVC.delegate = self
        self.present(contactVC, animated: true, completion: nil)
    }
    
    // MARK: Delegate method CNContectPickerDelegate
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let rawNumber = contact.phoneNumbers.first
        let firstName = contact.givenName
        let lastName = contact.familyName
        let alsoRawNumber = (rawNumber?.value)?.stringValue
        let number = alsoRawNumber?.tenChars()
        let fullName = "\(firstName) \(lastName)"
        
        if number != self.userPhoneNumber, number != nil, !fullName.trimmingCharacters(in: .whitespaces).isEmpty {
            self.listDict?[number!] = fullName
        }

        // Checks how many lists user is on
        self.checkForNameOnLists(phoneNumber: self.userPhoneNumber) { (lists) -> () in
            
            // resets listsUserIsOn
            self.listsUserIsOn = lists
            
            // changes text field in app
            self.listsUserIsOnText.text = "\(self.listsUserIsOn!.count)"
            
            // Now that we know new lists the user is on
            // check for any new matches
            self.checkForMatches(userList: self.listArray)
            self.tableView.reloadData()
            
            // Now that new matches have been checked for, sends notification for match or addition to list to added user
            if number != nil {
                self.sendPushNotification(to: number!)
            }
        }
        
    }
    
    // If you cancel adding a contact
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Takes any optional user phone number and returns
    // an array of all the people who have this phone number on their list
    // function uses a completion handler for async call
    func checkForNameOnLists(phoneNumber: String?, completion: @escaping ([String]) -> ()) {
        print("checkForNameOnLists gets called")
        var arrayOfUsersWhoHaveCurrentUserOnTheirList: [String] = []
        let userRef = self.ref.child("users")
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let listSnap = snap.childSnapshot(forPath: "list")
                let dict = listSnap.value as? [String : String]
                if phoneNumber != nil {
                    print("phoneNumber in checkForNameOnLists is not nil")
                    if dict?[phoneNumber!] != nil {
                        print("phoneNumber entry in database is not nil")
                        if let userWithCurrentUserOnList = snap.childSnapshot(forPath: "userPhoneNumber").value as? String {
                            arrayOfUsersWhoHaveCurrentUserOnTheirList.append(userWithCurrentUserOnList)
                        }
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
        
        
        if listArray != nil, listDict != nil {
            // If listArray count is 0 it will display default message
            if listArray!.count > 0 {
                let phoneNumber = listArray![indexPath.item]
                let crushName = listDict![phoneNumber]
                cell.listLabel.text = crushName
                
                // Logic to decide if this cell is a match or not
                if matches.count > 0, matches.contains(phoneNumber) {
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
            let dictKey = listArray?[indexPath.item]
            if dictKey != nil {
                listDict?[dictKey!] = nil
            }
            
            // Checks how many lists user is on and updates matches
            // Do we need this after a handle is deleted from a list?
            self.checkForNameOnLists(phoneNumber: self.userPhoneNumber) { (lists) -> () in
                self.listsUserIsOn = lists
                self.listsUserIsOnText.text = "\(self.listsUserIsOn!.count)"
                self.checkForMatches(userList: self.listArray)
                self.tableView.reloadData()
            }
        }
    }
    
    // Log Out segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LogOutSegue" {
            print("Logout segue runs!")
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
                for phoneNumber in matches {
                    if let index = tempList.firstIndex(of: phoneNumber) {
                        let matchedPhoneNumber = tempList.remove(at: index)
                        tempList.insert(matchedPhoneNumber, at: 0)
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
            for phoneNumber in userList! {
                if listsUserIsOn!.contains(phoneNumber) {
                    tempMatches.append(phoneNumber)
                }
            }
            matches = tempMatches
        }
    }
    
    func sendPushNotification(to phoneNumber: String) {
        
        var pushToken: String?
        
        let userRef = self.ref.child("users")
        
        // Grabbing the handle and pushToken for other user
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let phoneSnap = snap.childSnapshot(forPath: "userPhoneNumber")
                let pushTokenSnap = snap.childSnapshot(forPath: "pushToken")
                let databasePhoneNumber = phoneSnap.value as? String
                if phoneNumber == databasePhoneNumber {
                    pushToken = pushTokenSnap.value as? String
                }
            }
            // At this point the user had already added this other user to their list
            // Now we check if that "other user" has our user on their list
            // If so, we send "match" push notification, if not, other push notification
            if pushToken != nil {
                if self.listsUserIsOn != nil, self.listsUserIsOn!.contains(phoneNumber) {
                    let sender = PushNotificationSender()
                    sender.sendPushNotification(to: pushToken!, title: "", body: "You have a new match!")
                } else {
                    let sender = PushNotificationSender()
                    sender.sendPushNotification(to: pushToken!, title: "", body: "Someone added you to their list!")
                }
            }
        }
    }
    
    func loadUserList() {
        print("loadUserList gets called and firebaseUID is \(String(describing: firebaseUID))")
        // loads user's list
        ref.child("users/\(firebaseUID!)").observeSingleEvent(of: .value) { (snapshot) in
            if !snapshot.hasChild("list") {
                print("Starter list is assigned")
                // Assigns a starter list
                self.listDict = [:]
            } else {
                // retrieves list dictionary from Firebase
                let value = snapshot.value as? NSDictionary
                let codedListDict = value?["list"] as? [String : String]
                // Creates temporary dictionary to store decoded Firebase dictionary
                let tempListDict = codedListDict?.decode(dict: codedListDict)
                // Assigns the temp dictionary keys to be our listArray
                if tempListDict != nil {
                    self.listDict = tempListDict
                }
            }
            // Grabbing userHandle from Firebase
            if snapshot.hasChild("userPhoneNumber") {
                print("snapshot.hasChild contains userPhoneNumber in loadUserList")
                let value = snapshot.value as? NSDictionary
                if self.userPhoneNumber == nil {
                    let rawUserPhoneNumber = value?["userPhoneNumber"] as? String
                    self.userPhoneNumber = rawUserPhoneNumber?.tenChars()
                }
                print("userPhoneNumber in loadUserList before checkforNameOnList is \(String(describing: self.userPhoneNumber))")
                // Checks how many lists user is on
                self.checkForNameOnLists(phoneNumber: self.userPhoneNumber) { (lists) -> () in
                    print("lists after checkForNameOnLists is \(lists)")
                    self.listsUserIsOn = lists
                    self.listsUserIsOnText.text = "\(lists.count)"
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    
    
    
    
    
    
}

