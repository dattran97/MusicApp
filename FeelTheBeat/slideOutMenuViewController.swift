//
//  sideOutMenuViewController.swift
//  FeelTheBeat
//
//  Created by Dat on 7/20/16.
//  Copyright © 2016 trantuandat. All rights reserved.
//

import UIKit

class slideOutMenuViewController: UIViewController {
    
    @IBOutlet weak var profileMenu: UIView!
    @IBOutlet weak var imgUserAvatar: UIImageView!
    @IBOutlet weak var lblMess: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let headerArr:[String] = ["Tài khoản","Online","Offline","Thông tin"]
    var menuArr:[[String]] =
        [["Đăng nhập/Đăng ký"],
         ["Tìm kiếm bài hát", "Playlist online"],
         ["Nhạc của tui","Playlist của tui"],
         ["Cài đặt", "Hướng dẫn", "Giới thiệu", "Đăng xuất"]]
    var desViewArr:[UIViewController] = []
    //let viewArr:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        desViewArr.append(storyboard!.instantiateViewControllerWithIdentifier("SignInView") as! SignInViewController)
        desViewArr.append(storyboard!.instantiateViewControllerWithIdentifier("containerView") as! ContainerViewController)
        desViewArr.append(storyboard!.instantiateViewControllerWithIdentifier("containerView") as! ContainerViewController)
        desViewArr.append(storyboard!.instantiateViewControllerWithIdentifier("containerView") as! ContainerViewController)
        desViewArr.append(storyboard!.instantiateViewControllerWithIdentifier("containerView") as! ContainerViewController)
        desViewArr.append(storyboard!.instantiateViewControllerWithIdentifier("containerView") as! ContainerViewController)
        desViewArr.append(storyboard!.instantiateViewControllerWithIdentifier("containerView") as! ContainerViewController)
        desViewArr.append(storyboard!.instantiateViewControllerWithIdentifier("SignInView") as! SignInViewController)
        desViewArr.append(storyboard!.instantiateViewControllerWithIdentifier("SignInView") as! SignInViewController)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setProfile()
        if userInfo.uid != ""{
            menuArr[0][0] = "Thông tin tài khoản"
            desViewArr[0] = storyboard!.instantiateViewControllerWithIdentifier("profileView") as! profileViewController
            tableView.reloadData()
        }else{
            menuArr[0][0] = "Đăng nhập/Đăng ký"
            desViewArr[0] = storyboard!.instantiateViewControllerWithIdentifier("SignInView") as! SignInViewController
            tableView.reloadData()
        }
    }
    
    func setProfile(){
        if userInfo.uid == ""{
            imgUserAvatar.image = UIImage(named: "defaultUserAvatar")
            lblMess.text = "Chào bạn!                      "
        }else{
            if userInfo.avatarURL != ""{
                imgUserAvatar.loadImageFromUsingCache(userInfo.avatarURL)
            }else{
                imgUserAvatar.image = UIImage(named: "defaultUserAvatar")
            }
            lblMess.text = "Xin chào \(userInfo.lastName)!"
        }
        view.layoutIfNeeded()
        imgUserAvatar.layer.cornerRadius = self.imgUserAvatar.bounds.size.width/2
        imgUserAvatar.clipsToBounds = true
        self.view.backgroundColor = UIColor.whiteColor()
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}