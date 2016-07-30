//
//  loadImageExtension.swift
//  FeelTheBeat
//
//  Created by Dat on 7/8/16.
//  Copyright © 2016 trantuandat. All rights reserved.
//

import UIKit
import Alamofire

let imageCache = NSCache()

extension UIImageView{
    func loadImageFromUsingCache(urlString: String){
        //Load image online
        if urlString.hasPrefix("http"){
            self.image = nil
            //Check cache for image
            if let downloadedImage = imageCache.objectForKey(urlString) as? UIImage{
                self.image = downloadedImage
                return
            }
            
            //Otherwise fire off a new download
            Alamofire.request(.GET, urlString).responseData { (responseData) in
                if responseData.result.isFailure{
                    print(responseData.result.error)
                    return
                }
                if let downloadedImage = UIImage(data: responseData.result.value!){
                    imageCache.setObject(downloadedImage, forKey: urlString)
                    self.image = downloadedImage
                }else{
                    self.image = UIImage(named: "defaultUserAvatar")
                    return
                }
            }
        //Load image offline
        }else{
            let avatarDownloadedDicretory = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String).stringByAppendingString("/AvatarDownloaded")
            let avatarPath = avatarDownloadedDicretory.stringByAppendingString("/\(urlString)")
            if NSFileManager.defaultManager().fileExistsAtPath(avatarPath) {
                self.image = UIImage(contentsOfFile: avatarPath)
            }else{
                self.image = UIImage(named: "defaultSongAvatar")
            }
        }
    }
}
