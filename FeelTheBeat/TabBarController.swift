//
//  TabBarController.swift
//  mp3ZingClone
//
//  Created by Dat on 6/28/16.
//  Copyright © 2016 trantuandat. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    @IBOutlet weak var tabBarCustom: UITabBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        //Put tabbar into top of view
        tabBarCustom.frame = CGRectMake(0, UIApplication.sharedApplication().statusBarFrame.size.height, tabBarCustom.frame.size.width, tabBarCustom.frame.size.height)
        //Set tint color
        UITabBar.appearance().tintColor = UIColor(red:0.48, green:0.52, blue:0.99, alpha:1.0)
    }

    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
    }
}
