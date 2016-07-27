//
//  song.swift
//  FeelTheBeat
//
//  Created by Dat on 7/9/16.
//  Copyright © 2016 trantuandat. All rights reserved.
//

import UIKit

struct Song{
    var title:String
    var artist:String
    var id:String
    var siteId:String
    var host:String
    var avatarURL:String
    var sourceURL:String
    var lyricsURL:String
    var streamURL:String
    var quality:String
    
    init(){
        self.title = "Unknown"
        self.artist = "Unknown"
        self.id = ""
        self.siteId = ""
        self.host = "Unknown"
        self.avatarURL = ""
        self.sourceURL = ""
        self.lyricsURL = ""
        self.streamURL = ""
        self.quality = "128kpbs"
    }
    
    init(dic:Dictionary<String,AnyObject>){
        let code:String = "54db3d4b-518f-4f50-aa34-393147a8aa18"
        //SiteId
        if let siteId:String = dic["SiteId"] as? String{
            self.siteId = siteId
        }else{
            self.siteId = ""
        }
        //Lyrics URL
        if let lyricsURL:String = dic["LyricsUrl"] as? String{
            self.lyricsURL = lyricsURL + "&code=\(code)"
        }else{
            self.lyricsURL = ""
        }
        //Avatar URL
        if let avatarURL:String = dic["Avatar"] as? String{
            self.avatarURL = avatarURL + "&code=\(code)"
        }else{
            self.avatarURL = ""
        }
        //Stream URL
        if let downloadURL:String = dic["UrlJunDownload"] as? String{
            self.streamURL = downloadURL + "&code=\(code)"
        }else{
            self.streamURL = ""
        }
        //Source URL
        if let sourceURL:String = dic["UrlSource"] as? String{
            self.sourceURL = sourceURL
        }else{
            self.sourceURL = ""
        }
        //Id
        if let id:String = dic["Id"] as? String{
            self.id = id
        }else{
            self.id = ""
        }
        //Host, Quality
        self.quality = "320kbps"
        if let host:String = dic["HostName"] as? String{
            self.host = host
            if host == "chiasenhac.com"{
                self.quality = "500kbps"
            }
        }else{
            self.host = "Unknown"
        }
        //Artist
        if let artist:String = dic["Artist"] as? String{
            self.artist = artist
        }else{
            self.artist = "Unknown"
        }
        //Title
        if let title:String = dic["Title"] as? String{
            self.title = title
        }else{
            self.title = "Unknown"
        }
    }
}
