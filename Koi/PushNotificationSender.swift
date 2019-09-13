//
//  PushNotificationSender.swift
//  Koi
//
//  Created by john sanford on 9/10/19.
//  Copyright © 2019 Jack Sanford. All rights reserved.
//

import UIKit
class PushNotificationSender {
    
    func sendPushNotification(to token: String, title: String, body: String) {
        
        let urlString = "https://fcm.googleapis.com/fcm/send"
        
        let url = NSURL(string: urlString)!
        
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["user" : "test_id"]
        ]
        
        let request = NSMutableURLRequest(url: url as URL)
        
        request.httpMethod = "POST"
        
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAANj0v5mE:APA91bFaJ5P1HY4ggmu_Ld084JFhD66E04OjPjrnwjOfJg5SPbLqlPrqoG0NRvxIl1HxXAj9uN8P4NAo6UrOKRELTwtUVj3MismY70xnNcZPIMtWa-tue05bd2_1eRMY9MgFUt7zsZVK", forHTTPHeaderField: "Authorization")
        
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
