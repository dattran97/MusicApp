//
//  User.swift
//  FeelTheBeat
//
//  Created by Dat on 7/7/16.
//  Copyright © 2016 trantuandat. All rights reserved.
//

import UIKit
import Firebase

struct User{
    var uid:String!
    var fullName:String!
    var lastName:String!
    var email:String!
    var country:String!
    var birthday:Date!
    var avatarURL:String!
    var password:String!
    
    init(){
        self.uid = ""
        self.fullName = ""
        self.lastName = ""
        self.email = ""
        self.country = ""
        self.birthday = nil
        self.avatarURL = ""
    }
}
