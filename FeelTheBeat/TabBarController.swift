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
        tabBarCustom.frame = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.size.height, width: tabBarCustom.frame.size.width, height: tabBarCustom.frame.size.height)
        //Set tint color
        UITabBar.appearance().tintColor = UIColor(red:0.48, green:0.52, blue:0.99, alpha:1.0)
    }

    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
    }
}
