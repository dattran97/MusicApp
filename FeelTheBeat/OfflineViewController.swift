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
        searchBar.returnKeyType = UIReturnKeyType.Done
        //Set Done button always enable
        searchBar.enablesReturnKeyAutomatically = false
        //Hide border of UIsearchBar
        searchBar.backgroundImage = UIImage()
        searchBar.tintColor = UIColor.whiteColor()
        
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        songArrOffline = []
        //Search all .mp3 files and save info to array
        let songDownloadedDicretory = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String).stringByAppendingString("/SongDownloaded")
        var items:[String] = []
        do{
            items = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(songDownloadedDicretory)
        }catch{
            return
        }
        let appDe:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context:NSManagedObjectContext = appDe.managedObjectContext
        let request = NSFetchRequest(entityName: "SongData")
        do{
            let results = try context.executeFetchRequest(request)
            for item in items {
                if item.hasSuffix("mp3"){
                    var song:Song = Song()
                    for re in results{
                        if let streamURL:String = re.valueForKey("streamURL") as? String{
                            if streamURL == item.stringByReplacingOccurrencesOfString(".mp3", withString: ""){
                                if let title:String = re.valueForKey("title") as? String{
                                    song.title = title
                                }
                                if let artist:String = re.valueForKey("artist") as? String{
                                    song.artist = artist
                                }
                                if let host:String = re.valueForKey("host") as? String{
                                    song.host = host
                                }
                                if let quality:String = re.valueForKey("quality") as? String{
                                    song.quality = quality
                                }
                                if let sourceURL:String = re.valueForKey("sourceURL") as? String{
                                    song.sourceURL = sourceURL
                                }
                                if let avatarURL:String = re.valueForKey("avatarURL") as? String{
                                    song.avatarURL = avatarURL
                                }
                                if let lyrics:String = re.valueForKey("lyrics") as? String{
                                    song.lyricsURL = lyrics
                                }
                                song.streamURL = streamURL
                                songArrOffline.append(song)
                                break
                            }
                        }
                    }
                    if song.streamURL == "" {
                        song.streamURL = item.stringByReplacingOccurrencesOfString(".mp3", withString: "")
                        //Take title, artist default of file
                        let path = NSBundle.pathForResource(song.streamURL, ofType: "mp3", inDirectory: songDownloadedDicretory)
                        let url:NSURL = NSURL(fileURLWithPath: path!)
                        let playerItem = AVPlayerItem(URL: url)
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
            self.view.makeToast("Lỗi khi load dữ liệu, bạn vui lòng refresh lại tab", duration: 1, position: .Center)
        }
        songArrOffline = songArrOffline.reverse()
        if songArrOffline.count == 0{
            viewMess.hidden = false
            lblMess.text = "Thiết bị của bạn vẫn chưa download bài hát nào!"
        }else{
            viewMess.hidden = true
            tableView.reloadData()
        }
    }
    //---------Bar button item-----------
    @IBAction func barButtonSort(sender: AnyObject) {
        let appearance = SCLAlertView.SCLAppearance(
            kTitleTop: 30,
            kTitleHeight: 50,
            kWindowWidth: self.view.bounds.width * 8 / 10,
            showCloseButton: true
        )
        
        let alert = SCLAlertView(appearance: appearance)
        
        alert.addButton("Tên bài hát A -> Z", action: {
            self.songArrSorted = songArrOffline.sort { $0.title < $1.title }
            self.sortActive = true
            self.tableView.reloadData()
        })
        alert.addButton("Tên bài hát Z -> A", action: {
            self.songArrSorted = songArrOffline.sort { $0.title > $1.title }
            self.sortActive = true
            self.tableView.reloadData()
        })
        alert.addButton("Thời gian mới -> cũ", action: {
            self.sortActive = false
            self.tableView.reloadData()
        })
        alert.addButton("Thời gian cũ -> mới", action: {
            self.songArrSorted = songArrOffline.reverse()
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
            animationStyle: SCLAnimationStyle.TopToBottom
        )
    }
}




