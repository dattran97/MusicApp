//
//  firebaseSupportFunctions.swift
//  FeelTheBeat
//
//  Created by Dat on 7/23/16.
//  Copyright © 2016 trantuandat. All rights reserved.
//

import UIKit
import Firebase

class firebaseSupportFunctions: UIViewController {
    func initUserInfo(){
        if let user = FIRAuth.auth()?.currentUser{
            userInfo.uid = user.uid
            userInfo.email = user.email
            let queue = dispatch_queue_create("signIn", DISPATCH_QUEUE_CONCURRENT)
            dispatch_async(queue) {
                let ref = FIRDatabase.database().referenceFromURL("https://project-2302273330949501085.firebaseio.com/")
                ref.child("users").child(user.uid).observeEventType(.Value, withBlock: { snapshot in
                    if let fullName:String = snapshot.value!["name"] as? String {
                        userInfo.fullName = fullName
                        let fullNameArr = fullName.componentsSeparatedByString(" ")
                        userInfo.lastName = fullNameArr[fullNameArr.count - 1]
                    }
                    if let country:String = snapshot.value!["country"] as? String {
                        userInfo.country = country
                    }
                    if let birthday:String = snapshot.value!["birthday"] as? String {
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "dd/MM/yyyy"
                        userInfo.birthday = dateFormatter.dateFromString(birthday)
                    }
                    if let avatarURL:String = snapshot.value!["avatar"] as? String {
                        userInfo.avatarURL = avatarURL
                    }
                })
            }
        }
    }
}
