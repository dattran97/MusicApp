//
//  OfflineViewController.swift
//  mp3ZingClone
//
//  Created by Dat on 6/28/16.
//  Copyright © 2016 trantuandat. All rights reserved.
//

import UIKit
import SCLAlertView
import AVFoundation
import CoreData

class OfflineViewController: handleRowActions{
    @IBOutlet weak var viewMess: UIView!
    @IBOutlet weak var lblMess: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    var searchBarActive:Bool = false
    var sortActive:Bool = false
    var songArrFiltered:[Song] = []
    var songArrSorted:[Song] = []
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        songArrOffline = []
        //Search all .mp3 files and save info to array
        let songDownloadedDicretory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String) + "/SongDownloaded"
        var items:[String] = []
        do{
            items = try FileManager.default.contentsOfDirectory(atPath: songDownloadedDicretory)
        }catch{
            return
        }
        let appDe:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDe.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SongData")
        do{
            let results = try context.fetch(request)
            for item in items {
                if item.hasSuffix("mp3"){
                    var song:Song = Song()
                    for re in results{
                        if let streamURL:String = (re as AnyObject).value(forKey: "streamURL") as? String{
                            if streamURL == item.replacingOccurrences(of: ".mp3", with: ""){
                                if let title:String = (re as AnyObject).value(forKey: "title") as? String{
                                    song.title = title
                                }
                                if let artist:String = (re as AnyObject).value(forKey: "artist") as? String{
                                    song.artist = artist
                                }
                                if let host:String = (re as AnyObject).value(forKey: "host") as? String{
                                    song.host = host
                                }
                                if let quality:String = (re as AnyObject).value(forKey: "quality") as? String{
                                    song.quality = quality
                                }
                                if let sourceURL:String = (re as AnyObject).value(forKey: "sourceURL") as? String{
                                    song.sourceURL = sourceURL
                                }
                                if let avatarURL:String = (re as AnyObject).value(forKey: "avatarURL") as? String{
                                    song.avatarURL = avatarURL
                                }
                                if let lyrics:String = (re as AnyObject).value(forKey: "lyrics") as? String{
                                    song.lyricsURL = lyrics
                                }
                                song.streamURL = streamURL
                                songArrOffline.append(song)
                                break
                            }
                        }
                    }
                    if song.streamURL == "" {
                        song.streamURL = item.replacingOccurrences(of: ".mp3", with: "")
                        //Take title, artist default of file
                        let path = Bundle.path(forResource: song.streamURL, ofType: "mp3", inDirectory: songDownloadedDicretory)
                        let url:URL = URL(fileURLWithPath: path!)
                        let playerItem = AVPlayerItem(url: url)
                        let metadataList = playerItem.asset.commonMetadata
                        for item in metadataList {
                            if let stringValue = item.value as? String {
                                if item.commonKey == "title" {
                                    song.title = stringValue
                                }
                                if item.commonKey == "artist" {
                                    song.artist = stringValue
                                }
                                if item.commonKey == "albumName"{
                                    song.host = stringValue
                                }
                            }
                        }
                        songArrOffline.append(song)
                    }
                    if songArrOffline.count < results.count{
                        //Clear cache
                    }
                }
            }
        }catch{
            self.view.makeToast("Lỗi khi load dữ liệu, bạn vui lòng refresh lại tab", duration: TimeInterval(1), position: .Center)
        }
        songArrOffline = songArrOffline.reversed()
        if songArrOffline.count == 0{
            viewMess.isHidden = false
            lblMess.text = "Thiết bị của bạn vẫn chưa download bài hát nào!"
        }else{
            viewMess.isHidden = true
            tableView.reloadData()
        }
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
        
        alert.addButton("Tên bài hát A -> Z", action: {
            self.songArrSorted = songArrOffline.sorted { $0.title < $1.title }
            self.sortActive = true
            self.tableView.reloadData()
        })
        alert.addButton("Tên bài hát Z -> A", action: {
            self.songArrSorted = songArrOffline.sorted { $0.title > $1.title }
            self.sortActive = true
            self.tableView.reloadData()
        })
        alert.addButton("Thời gian mới -> cũ", action: {
            self.sortActive = false
            self.tableView.reloadData()
        })
        alert.addButton("Thời gian cũ -> mới", action: {
            self.songArrSorted = songArrOffline.reversed()
            self.sortActive = true
            self.tableView.reloadData()
        })
        alert.showNotice(
            "Sắp xếp theo: ",
            subTitle: "",
            closeButtonTitle: "Đóng",
            duration: 0,
            colorStyle: 8094972,
            colorTextButton: 16777215,
            circleIconImage: nil,
            animationStyle: SCLAnimationStyle.topToBottom
        )
    }
}




