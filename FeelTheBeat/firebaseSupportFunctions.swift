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
        if let user = Auth.auth().currentUser{
            userInfo.uid = user.uid
            userInfo.email = user.email
            let queue = DispatchQueue(label: "signIn", attributes: DispatchQueue.Attributes.concurrent)
            queue.async {
                let ref = Database.database().reference(fromURL: "https://project-2302273330949501085.firebaseio.com/")
                ref.child("users").child(user.uid).observe(.value, with: { snapshot in
                    if let fullName:String = snapshot.value(forKey: "name") as? String {
                        userInfo.fullName = fullName
                        let fullNameArr = fullName.components(separatedBy: " ")
                        userInfo.lastName = fullNameArr[fullNameArr.count - 1]
                    }
                    if let country:String = snapshot.value(forKey: "country") as? String {
                        userInfo.country = country
                    }
                    if let birthday:String = snapshot.value(forKey: "birthday") as? String {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd/MM/yyyy"
                        userInfo.birthday = dateFormatter.date(from: birthday) as! Date
                    }
                    if let avatarURL:String = snapshot.value(forKey: "avatar") as? String {
                        userInfo.avatarURL = avatarURL
                    }
                })
            }
        }
    }
}
