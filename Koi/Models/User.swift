//
//  User.swift
//  Koi
//
//  Created by john sanford on 8/27/19.
//  Copyright © 2019 Jack Sanford. All rights reserved.
//

import Foundation
import Firebase

struct User: Hashable {
    
    struct Crush: Hashable {
        
        let crushHandle: String
        var isAMatch = false
        
        init(crushHandle: String) {
            self.crushHandle = crushHandle
        }
        
    }
    
    let instaUID: String
    let userHandle: String
    var crushDict: [Crush:Bool] = [:]
    
    init(instaUID: String, userHandle: String) {
        self.instaUID = instaUID
        self.userHandle = userHandle
    }
    
}
