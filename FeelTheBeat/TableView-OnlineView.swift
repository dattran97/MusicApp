//
//  CustomTableView-OnlineViewController.swift
//  FeelTheBeat
//
//  Created by Dat on 7/12/16.
//  Copyright © 2016 trantuandat. All rights reserved.
//

import UIKit
import Kingfisher

//-------------------------------Custom TableView---------------------------------------
extension OnlineViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 
        return songArrOnline.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        if !(indexPath.row > songArrOnline.count - 1) {
            cell.lblTitle?.text = songArrOnline[indexPath.row].title
            cell.lblArtist?.text = songArrOnline[indexPath.row].artist
            cell.lblSource?.text = songArrOnline[indexPath.row].host
            if songArrOnline[indexPath.row].avatarURL != ""{
                cell.imgAvatar.kf.setImage(with: URL(string: songArrOnline[indexPath.row].avatarURL))
            }else{
                cell.imgAvatar.image = UIImage(named: "defaultSongAvatar")
            }
            cell.lblQuality?.text = songArrOnline[indexPath.row].quality
            cell.lblQuality?.layer.cornerRadius = 10
            cell.lblQuality?.layer.borderWidth = 1
            cell.lblQuality?.layer.borderColor = cell.lblTitle.textColor.cgColor
            cell.lblQuality?.textColor = cell.lblTitle.textColor
            cell.lblQuality?.clipsToBounds = true
            cell.imgAvatar?.layer.cornerRadius = cell.imgAvatar.frame.size.width/2
            cell.imgAvatar?.clipsToBounds = true
            cell.imgAvatar?.tintColor = UIColor(red:0.48, green:0.52, blue:0.99, alpha:1.0)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if songArrOnline.count > 0{
            songSelected = indexPath.row
            songArr = songArrOnline
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "PlayerView") as! PlayerViewController
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var footerHeight:CGFloat = 0
        if section == 0 && player != nil{
            footerHeight = self.view.frame.size.height/10
        }
        return footerHeight
    }
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //Button "Download"
        let downloadButton = UITableViewRowAction(style: .default, title: "         ", handler: { (action, indexPath) in
            //Handle Download
            self.handleDownloadSong(songArrOnline[indexPath.row])
        })
        if let img1 = UIImage(named: "rowActionDownload") {
            downloadButton.backgroundColor = UIColor.imageWithBackgroundColor(img1, bgColor: UIColor.red)
        }
        //Button "Add to playlist"
        let addPlaylistButton = UITableViewRowAction(style: .default, title: "         ", handler: { (action, indexPath) in
            self.handleAddSongToPlaylist(indexPath.row)
        })
        if let img2 = UIImage(named: "rowActionAddPlaylist") {
            addPlaylistButton.backgroundColor = UIColor.imageWithBackgroundColor(img2, bgColor: UIColor(red:0.48, green:0.52, blue:0.99, alpha:1.0))
        }
        return [downloadButton, addPlaylistButton]
    }
}
