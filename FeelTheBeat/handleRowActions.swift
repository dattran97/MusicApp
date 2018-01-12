//
//  handleRowActions.swift
//  FeelTheBeat
//
//  Created by Dat on 7/25/16.
//  Copyright © 2016 trantuandat. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
import Toast_Swift
import CoreData

class handleRowActions: UIViewController {
    func handleDownloadSong(_ song:Song){
        var songDownloadedName:String!
        var avatarDownloadedName:String!
        self.view.makeToast("Đang tải về bài hát \(song.title)", duration: TimeInterval(1), position: .Center)
        //Create Directory
        let documentsPath = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        var songPath = documentsPath.appendingPathComponent("SongDownloaded")
        var imagePath = documentsPath.appendingPathComponent("AvatarDownloaded")
        if !FileManager.default.fileExists(atPath: songPath.path){
            do {
                try FileManager.default.createDirectory(atPath: songPath.path, withIntermediateDirectories: true, attributes: nil)
            }catch  {
                print("Unable to create song directory ")
                return
            }
        }
        //Handle download with Alamofire
        Alamofire.download(.get, song.streamURL, destination: { (temporaryURL, response) in
            let date = Date()
            let myDateString = String(Int64(date.timeIntervalSince1970*1000))
            songDownloadedName = myDateString + "-" + response.suggestedFilename!
            songPath = songPath.URLByAppendingPathComponent(songDownloadedName)
            if NSFileManager.defaultManager().fileExistsAtPath(songPath.path!) {
                do{
                    try NSFileManager.defaultManager().removeItemAtPath(songPath.path!)
                }catch {}
            }
            return songPath
        }).response { request, response, _, error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.view.makeToast("Có lỗi xảy ra khi tải bài hát", duration: 1, position: .Center)
                })
                return
            } else {
                //Success to download song
                //Download avatar
                if !NSFileManager.defaultManager().fileExistsAtPath(imagePath.path!){
                    do {
                        try NSFileManager.defaultManager().createDirectoryAtPath(imagePath.path!, withIntermediateDirectories: true, attributes: nil)
                    }catch  {
                        print("Unable to create image directory ")
                        return
                    }
                }
                let date = NSDate()
                let myDateString = String(Int64(date.timeIntervalSince1970*1000))
                avatarDownloadedName = myDateString + "-" + response!.suggestedFilename!.stringByReplacingOccurrencesOfString(".mp3", withString: ".png")
                imagePath = imagePath.URLByAppendingPathComponent(avatarDownloadedName)
                if NSFileManager.defaultManager().fileExistsAtPath(imagePath.path!) {
                    do{
                        try NSFileManager.defaultManager().removeItemAtPath(imagePath.path!)
                    }catch {}
                }
                let imageView:UIImageView = UIImageView()
                imageView.loadImageFromUsingCache(song.avatarURL)
                let pngImageData = UIImagePNGRepresentation(imageView.image!)
                pngImageData!.writeToFile(imagePath.path!, atomically: true)
                //Save data to Core data
                let appDe:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let context:NSManagedObjectContext = appDe.managedObjectContext
                let newSong = NSEntityDescription.insertNewObjectForEntityForName("SongData", inManagedObjectContext: context)
                newSong.setValue(songDownloadedName.stringByReplacingOccurrencesOfString(".mp3", withString: ""), forKey: "streamURL")
                newSong.setValue(avatarDownloadedName, forKey: "avatarURL")
                newSong.setValue(song.title, forKey: "title")
                newSong.setValue(song.artist, forKey: "artist")
                newSong.setValue(song.host, forKey: "host")
                newSong.setValue(song.quality, forKey: "quality")
                newSong.setValue(song.sourceURL, forKey: "sourceURL")
                let url = NSURL(string: song.lyricsURL)
                Alamofire.request(.GET, url!).responseString(completionHandler: { (response) in
                    if response.result.error != nil{
                        print("Lỗi khi tải lời bài hát")
                        newSong.setValue("", forKey: "lyrics")
                    }
                    let lyrics = String(htmlEncodedString: response.result.value!)
                    newSong.setValue(lyrics, forKey: "lyrics")
                    do{
                        try context.save()
                        self.view.makeToast("Đã tải thành công bài hát \(song.title)", duration: 1, position: .Center)
                    } catch{
                        print("Lỗi khi lưu database")
                    }
                })
            }
        }
    }

    func handleAddSongToPlaylist(_ songSelected:Int){
    
    }
    
    func handleDeleteSong(_ downloadURL: String, sourceURL:String) -> Bool{
        let appDe:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDe.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SongData")
        do{
            let results = try context.fetch(request)
            for re in results{
                if let source:String = (re as AnyObject).value(forKey: "sourceURL") as? String, source == sourceURL{
                    let songDownloadedPath:String = ((re as AnyObject).value(forKey: "streamURL") as? String)!
                    if let _:AVPlayer = player{
                        //Check if player is playing
                        let currentPlayerAsset = player.currentItem?.asset
                        var url:String = (currentPlayerAsset as! AVURLAsset).url.absoluteString
                        url = url.replacingOccurrences(of: ".mp3", with: "")
                        if url.hasSuffix("/\(downloadURL)"){
                            self.view.makeToast("Bài hát đang phát, không thể xóa", duration: TimeInterval(1), position: .Center)
                            return false
                        }
                    }
                    let documentsPath = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
                    let downloadPath = documentsPath.appendingPathComponent("SongDownloaded")
                    let songPath = downloadPath.appendingPathComponent(songDownloadedPath+".mp3")
                    do{
                        try FileManager.default.removeItem(atPath: songPath.path)
                        context.delete(re as! NSManagedObject)
                        do{
                            try context.save()
                            self.view.makeToast("Đã xóa thành công", duration: TimeInterval(1), position: .Center)
                            return true
                        }catch{
                            self.view.makeToast("Xảy ra sự cố khi xóa dữ liệu bài hát", duration: TimeInterval(1), position: .Center)
                            return false
                        }
                    }catch{
                        self.view.makeToast("Xảy ra sự cố khi xóa bài hát", duration: TimeInterval(1), position: .Center)
                        return false
                    }
                }
            }
            return false
        }catch{
            self.view.makeToast("Xảy ra sự cố khi xóa dữ liệu bài hát", duration: TimeInterval(1), position: .Center)
            return false
        }
    }
}
