//
//  ContainerViewController.swift
//  FeelTheBeat
//
//  Created by Dat on 7/19/16.
//  Copyright © 2016 trantuandat. All rights reserved.
//

import UIKit

class ContainerViewController: firebaseSupportFunctions {
    
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var subPlayerContainer: UIView!

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        initUserInfo()
        if player == nil{
            subPlayerContainer.hidden = true
        }else{
            subPlayerContainer.hidden = false
        }
        subPlayerContainer.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(ContainerViewController.dragSubPlayerView)))
    }
    @IBAction func dragSubPlayerView(recognizer: UIPanGestureRecognizer) {
        let point = recognizer.locationInView(self.view);
        if(recognizer.state == .Ended){
            if point.y < self.view.frame.height/2{
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("PlayerView") as! PlayerViewController
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }
    }
}
