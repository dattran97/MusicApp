//
//  TableView-OfflineView.swift
//  FeelTheBeat
//
//  Created by Dat on 7/13/16.
//  Copyright © 2016 trantuandat. All rights reserved.
//

import UIKit

//-------------------------------Custom TableView---------------------------------------
extension OfflineViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBarActive{
            if songArrFiltered.count == 0{
                viewMess.hidden = false
                lblMess.text = "Rất tiếc, chúng tôi không tìm thấy bài hát mà bạn yêu cầu!"
            }else{
                viewMess.hidden = true
            }
            return songArrFiltered.count
        }else{
            return songArrOffline.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TableViewCell
        if searchBarActive{
            cell.lblTitle.text = songArrFiltered[indexPath.row].title
            cell.lblArtist.text = songArrFiltered[indexPath.row].artist
            cell.lblSource.text = songArrFiltered[indexPath.row].host
            cell.lblQuality.text = songArrFiltered[indexPath.row].quality
            cell.imgAvatar.loadImageFromUsingCache(songArrFiltered[indexPath.row].avatarURL)
        }else{
            if sortActive{
                cell.lblTitle.text = songArrSorted[indexPath.row].title
                cell.lblArtist.text = songArrSorted[indexPath.row].artist
                cell.lblSource.text = songArrSorted[indexPath.row].host
                cell.lblQuality.text = songArrSorted[indexPath.row].quality
                cell.imgAvatar.loadImageFromUsingCache(songArrSorted[indexPath.row].avatarURL)
            }else{
                cell.lblTitle.text = songArrOffline[indexPath.row].title
                cell.lblArtist.text = songArrOffline[indexPath.row].artist
                cell.lblSource.text = songArrOffline[indexPath.row].host
                cell.lblQuality.text = songArrOffline[indexPath.row].quality
                cell.imgAvatar.loadImageFromUsingCache(songArrOffline[indexPath.row].avatarURL)
            }
        }
        cell.lblQuality.layer.cornerRadius = 10
        cell.lblQuality.layer.borderWidth = 1
        cell.lblQuality.layer.borderColor = cell.lblTitle.textColor.CGColor
        cell.lblQuality.textColor = cell.lblTitle.textColor
        cell.lblQuality.clipsToBounds = true
        cell.imgAvatar.layer.cornerRadius = cell.imgAvatar.frame.size.width/2
        cell.imgAvatar.clipsToBounds = true
        cell.imgAvatar.tintColor = UIColor(red:0.48, green:0.52, blue:0.99, alpha:1.0)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if songArrOffline.count > 0{
            if searchBarActive{
                for i in 0..<songArrOffline.count{
                    if songArrOffline[i].title == songArrFiltered[indexPath.row].title{
                        songSelected = i
                        songArr = songArrOffline
                    }
                }
            }else{
                if sortActive{
                    songSelected = indexPath.row
                    songArr = songArrSorted
                }else{
                    songSelected = indexPath.row
                    songArr = songArrOffline
                }
            }
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("PlayerView") as! PlayerViewController
            self.presentViewController(vc, animated: true, completion: nil)
        }
        
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var footerHeight:CGFloat = 0
        if section == 0 && player != nil{
            footerHeight = self.view.frame.size.height/10
        }
        return footerHeight
    }
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.whiteColor()
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        //Button "Delete"
        let deleteButton = UITableViewRowAction(style: .Default, title: "         ", handler: { (action, indexPath) in
            if self.handleDeleteSong(songArrOffline[indexPath.row].streamURL, sourceURL: songArrOffline[indexPath.row].sourceURL){
                if songArr.count > 0{
                    if songArr[indexPath.row].streamURL == songArrOffline[indexPath.row].streamURL{
                        songArr.removeAtIndex(indexPath.row)
                    }
                }
                songArrOffline.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        })
        if let img1 = UIImage(named: "rowActionTrash") {
            deleteButton.backgroundColor = UIColor.imageWithBackgroundColor(img1, bgColor: UIColor.redColor())
        }
        //Button "Add to playlist"
        let addPlaylistButton = UITableViewRowAction(style: .Default, title: "         ", handler: { (action, indexPath) in
            print("Add to Playlist")
        })
        if let img2 = UIImage(named: "rowActionAddPlaylist") {
            addPlaylistButton.backgroundColor = UIColor.imageWithBackgroundColor(img2, bgColor: UIColor(red:0.48, green:0.52, blue:0.99, alpha:1.0))
        }
        return [deleteButton, addPlaylistButton]
    }
}