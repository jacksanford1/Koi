//
//  Utilities.swift
//  Koi
//
//  Created by john sanford on 8/29/19.
//  Copyright © 2019 Jack Sanford. All rights reserved.
//

import Foundation
import UIKit

extension Dictionary where Key == String, Value == String {
    func encode(dict: [String:String]?) -> Dictionary {
        var newList: [String:String] = [:]
        if dict != nil {
            for (key, value) in dict! {
                let customCharSet = (CharacterSet(charactersIn: ".$#[]/%").inverted)
                let encodedKey = key.addingPercentEncoding(withAllowedCharacters: customCharSet)
                let encodedValue = value.addingPercentEncoding(withAllowedCharacters: customCharSet)
                if encodedKey != nil {
                    newList[encodedKey!] = encodedValue
                }
            }
        }
        return newList
    }
    
    func decode(dict: [String:String]?) -> Dictionary {
        var newList: [String:String] = [:]
        if dict != nil {
            for (key, value) in dict! {
                let decodedKey = key.removingPercentEncoding
                let decodedValue = value.removingPercentEncoding
                if decodedKey != nil {
                    newList[decodedKey!] = decodedValue
                }
            }
        }
        return newList
    }
    
    func key(for value: String) -> String? {
        return compactMap { value == $1 ? $0 : nil }.first
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
    
    func tenChars() -> String {
        var tenCharNumber = self
        tenCharNumber = tenCharNumber.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range: nil)
        tenCharNumber = tenCharNumber.replacingOccurrences(of: "(", with: "", options: NSString.CompareOptions.literal, range: nil)
        tenCharNumber = tenCharNumber.replacingOccurrences(of: ")", with: "", options: NSString.CompareOptions.literal, range: nil)
        tenCharNumber = tenCharNumber.replacingOccurrences(of: "+", with: "", options: NSString.CompareOptions.literal, range: nil)
        tenCharNumber = tenCharNumber.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
        if tenCharNumber.count > 10 {
            let numberToRemove = tenCharNumber.count - 10
            tenCharNumber = String(tenCharNumber.dropFirst(numberToRemove))
        }
        return tenCharNumber
    }
    
}

extension UIColor {
    static let deepBlue = UIColor(red: 5.0/255.0, green: 5.0/255.0 ,blue: 30.0/255.0, alpha: 1.0)
    static let sharpRed = UIColor(red: 255.0/255.0, green: 29.0/255.0 ,blue: 57.0/255.0, alpha: 1.0)
    static let cyan = UIColor(red: 0.0/255.0, green: 255.0/255.0 ,blue: 255.0/255.0, alpha: 1.0)
    static let risingSun = UIColor(red: 251.0/255.0, green: 176.0/255.0 ,blue: 64.0/255.0, alpha: 1.0)
    static let trueBlue = UIColor(red: 65.0/255.0, green: 185.0/255.0 ,blue: 245.0/255.0, alpha: 1.0)
}

extension NSMutableAttributedString {
    
    public func setAsLink(textToFind:String, linkURL:String) {
        
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: linkURL, range: foundRange)
        }
    }
}
