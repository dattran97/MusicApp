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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        initUserInfo()
        if player == nil{
            subPlayerContainer.isHidden = true
        }else{
            subPlayerContainer.isHidden = false
        }
        subPlayerContainer.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(ContainerViewController.dragSubPlayerView)))
    }
    @IBAction func dragSubPlayerView(_ recognizer: UIPanGestureRecognizer) {
        let point = recognizer.location(in: self.view);
        if(recognizer.state == .ended){
            if point.y < self.view.frame.height/2{
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "PlayerView") as! PlayerViewController
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
}
