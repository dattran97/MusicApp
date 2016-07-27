//
//  playerSupportFunctions.swift
//  FeelTheBeat
//
//  Created by Dat on 6/27/16.
//  Copyright © 2016 trantuandat. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

var player:AVPlayer!
var playerItem:AVPlayerItem!
var songSelected = -1
var songArr:[Song] = []
var songArrOnline:[Song] = []
var songArrOffline:[Song] = []
var songArrShuffed:[Int] = []
var userInfo:User = User()
var volumeValue:Float = 0.5
///repeatAll | repeatOne | shuffe
var playerMode:String = "repeatAll"

class baseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
//--------------------------------------Support function--------------------------------------    
    func setSong(songSelected:Int){
        var url = NSURL(string: songArr[songSelected].streamURL)
        if !(songArr[songSelected].streamURL.hasPrefix("http")){
            let songDownloadedDicretory = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String).stringByAppendingString("/SongDownloaded")
            let path = NSBundle.pathForResource(songArr[songSelected].streamURL, ofType: "mp3", inDirectory: songDownloadedDicretory)
            url = NSURL(fileURLWithPath: path!)
        }
        do{
            playerItem = AVPlayerItem(URL: url!)
            player = AVPlayer(playerItem: playerItem)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        }catch{
            print("Không thể phát bài hát")
        }
        player.volume = volumeValue
    }
    
    func changeSong(isNext:Bool){
        if playerMode == "shuffe"{
            for i in 0..<songArrShuffed.count{
                if songArrShuffed[i] == songSelected{
                    if isNext == true {
                        if i + 1 == songArrShuffed.count{
                            songSelected = songArrShuffed[0]
                        }else{
                            songSelected = songArrShuffed[i+1]
                        }
                    }else{
                        if i == 0{
                            songSelected = songArrShuffed[songArrShuffed.count - 1]
                        }else{
                            songSelected = songArrShuffed[i-1]
                        }
                    }
                    break
                }
            }
        }else{
            if playerItem.currentTime().timescale != playerItem.asset.duration.timescale || playerMode != "repeatOne"{
                if isNext == true {
                    if songSelected == songArr.count - 1{
                        songSelected = 0
                    }else{
                        songSelected += 1
                    }
                }else{
                    if songSelected == 0 {
                        songSelected = songArr.count - 1
                    }else{
                        songSelected -= 1
                    }
                }
            }
        }
        player.pause()
        setSong(songSelected)
        player.play()
    }
}
