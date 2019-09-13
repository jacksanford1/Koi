//
//  Utilities.swift
//  Koi
//
//  Created by john sanford on 8/29/19.
//  Copyright © 2019 Jack Sanford. All rights reserved.
//

import Foundation
import UIKit

extension Dictionary where Key == String, Value == Bool {
    func encode(dict: [String:Bool]?) -> Dictionary {
        var newList: [String:Bool] = [:]
        if dict != nil {
            for (key, value) in dict! {
                let customCharSet = (CharacterSet(charactersIn: ".$#[]/%").inverted)
                let encodedKey = key.addingPercentEncoding(withAllowedCharacters: customCharSet)
                if encodedKey != nil {
                    newList[encodedKey!] = value
                }
            }
        }
        return newList
    }
    
    func decode(dict: [String:Bool]?) -> Dictionary {
        var newList: [String:Bool] = [:]
        if dict != nil {
            for (key, value) in dict! {
                let decodedKey = key.removingPercentEncoding
                if decodedKey != nil {
                    newList[decodedKey!] = value
                }
            }
        }
        return newList
    }
}

extension String {
    
    func noAtSymbol() -> String {
        var noAtHandle = self
        if self.hasPrefix("@") {
            noAtHandle = String(self.dropFirst())
        }
        return noAtHandle
    }
    
    func withAtSymbol() -> String {
        var noAtHandle = self
        if !self.hasPrefix("@") {
            noAtHandle = "@\(noAtHandle)"
        }
        return noAtHandle
    }
    
}

extension UIColor {
    static let deepBlue = UIColor(red: 5.0/255.0, green: 5.0/255.0 ,blue: 30.0/255.0, alpha: 1.0)
    static let sharpRed = UIColor(red: 255.0/255.0, green: 29.0/255.0 ,blue: 57.0/255.0, alpha: 1.0)
    static let cyan = UIColor(red: 0.0/255.0, green: 255.0/255.0 ,blue: 255.0/255.0, alpha: 1.0)
    static let risingSun = UIColor(red: 251.0/255.0, green: 176.0/255.0 ,blue: 64.0/255.0, alpha: 1.0)
    static let trueBlue = UIColor(red: 65.0/255.0, green: 185.0/255.0 ,blue: 245.0/255.0, alpha: 1.0)
}


