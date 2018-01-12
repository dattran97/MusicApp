//
//  OnlineViewController.swift
//  FeelTheBeat
//
//  Created by Dat on 7/3/16.
//  Copyright © 2016 trantuandat. All rights reserved.
//

import UIKit
import SCLAlertView

class OnlineViewController: handleRowActions{
    @IBOutlet weak var viewMess: UIView!
    @IBOutlet weak var imgMess: UIImageView!
    @IBOutlet weak var lblMess: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    var searchBarActive:Bool = false
    var sortActive:Bool = false
    var playListFiltered:[String] = []
    var playListSorted:[String] = []
    
    var loadingView: UIView = UIView()
    var activityIndicatorView:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    ///ID of source
    var sourceIndex:Int = 0
    let source:[String] = ["nhaccuatui.com", "mp3.zing.vn", "chiasenhac.com"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        //Set Done button in keyboard
        searchBar.returnKeyType = UIReturnKeyType.done
        //Set Done button always enable
        searchBar.enablesReturnKeyAutomatically = false
        //Hide border of UIsearchBar
        searchBar.backgroundImage = UIImage()
        searchBar.tintColor = UIColor.white
        
        tableView.delegate = self
        tableView.dataSource = self
        //TableViewCell auto rowheight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200
        
        //Side bar menu
        if revealViewController() != nil {
            menuBarButton.target = revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
        viewMess.isHidden = false
        lblMess.text = "Hãy nhập tên bài hát cần tìm vào thanh search ở trên"
        
        //Custom ActivityIndicatorView
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = view.center
        loadingView.backgroundColor = UIColor.black
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10

        activityIndicatorView.center = CGPoint(x: loadingView.frame.size.width / 2,
                                    y: loadingView.frame.size.height / 2);
        loadingView.addSubview(activityIndicatorView)
        view.addSubview(loadingView)
        activityIndicatorView.startAnimating()
        loadingView.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        tableView.reloadData()
    }
    //---------Bar button item-----------
    @IBAction func barButtonSort(_ sender: AnyObject) {
        let appearance = SCLAlertView.SCLAppearance(
            kTitleTop: 30,
            kTitleHeight: 50,
            kWindowWidth: self.view.bounds.width * 8 / 10,
            showCloseButton: true
        )
        
        let alert = SCLAlertView(appearance: appearance)
        
        alert.addButton("Tên bài hát", action: {
        })
        alert.addButton("Tên playlist", action: {
        })
        alert.showNotice(
            "Tìm kiếm theo: ",
            subTitle: "",
            closeButtonTitle: "Đóng",
            duration: 0,
            colorStyle: 8094972,
            colorTextButton: 16777215,
            circleIconImage: nil,
            animationStyle: SCLAnimationStyle.topToBottom
        )
        showResults(searchBar.text!)
    }
}


