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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBarActive{
            if songArrFiltered.count == 0{
                viewMess.isHidden = false
                lblMess.text = "Rất tiếc, chúng tôi không tìm thấy bài hát mà bạn yêu cầu!"
            }else{
                viewMess.isHidden = true
            }
            return songArrFiltered.count
        }else{
            return songArrOffline.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        if searchBarActive{
            cell.lblTitle.text = songArrFiltered[indexPath.row].title
            cell.lblArtist.text = songArrFiltered[indexPath.row].artist
            cell.lblSource.text = songArrFiltered[indexPath.row].host
            cell.lblQuality.text = songArrFiltered[indexPath.row].quality
            cell.imgAvatar.kf.setImage(with: URL(string: songArrFiltered[indexPath.row].avatarURL))
        }else{
            if sortActive{
                cell.lblTitle.text = songArrSorted[indexPath.row].title
                cell.lblArtist.text = songArrSorted[indexPath.row].artist
                cell.lblSource.text = songArrSorted[indexPath.row].host
                cell.lblQuality.text = songArrSorted[indexPath.row].quality
                cell.imgAvatar.kf.setImage(with: URL(string: songArrSorted[indexPath.row].avatarURL))
            }else{
                cell.lblTitle.text = songArrOffline[indexPath.row].title
                cell.lblArtist.text = songArrOffline[indexPath.row].artist
                cell.lblSource.text = songArrOffline[indexPath.row].host
                cell.lblQuality.text = songArrOffline[indexPath.row].quality
                cell.imgAvatar.kf.setImage(with: URL(string: songArrOffline[indexPath.row].avatarURL))
            }
        }
        cell.lblQuality.layer.cornerRadius = 10
        cell.lblQuality.layer.borderWidth = 1
        cell.lblQuality.layer.borderColor = cell.lblTitle.textColor.cgColor
        cell.lblQuality.textColor = cell.lblTitle.textColor
        cell.lblQuality.clipsToBounds = true
        cell.imgAvatar.layer.cornerRadius = cell.imgAvatar.frame.size.width/2
        cell.imgAvatar.clipsToBounds = true
        cell.imgAvatar.tintColor = UIColor(red:0.48, green:0.52, blue:0.99, alpha:1.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        //Button "Delete"
        let deleteButton = UITableViewRowAction(style: .default, title: "         ", handler: { (action, indexPath) in
            //Get song to delete
            var song:Song = Song()
            if self.searchBarActive{
                song = self.songArrFiltered[indexPath.row]
            }else{
                if self.sortActive{
                    song = self.songArrSorted[indexPath.row]
                }else{
                    song = songArrOffline[indexPath.row]
                }
            }
            //Delete in device
            if self.handleDeleteSong(song.streamURL, sourceURL: song.sourceURL){
                //Delete song in songArr
                if songArr.count > 0{
                    for i in 0..<songArr.count {
                        if songArr[i].streamURL == song.streamURL{
                            songArr.remove(at: i)
                            if i < songSelected{
                                songSelected -= 1
                            }
                            break
                        }
                    }
                }
                //Delete song in tableView
                if self.searchBarActive{
                    for i in 0..<songArrOffline.count{
                        if self.songArrFiltered[indexPath.row].streamURL == songArrOffline[i].streamURL{
                            songArrOffline.remove(at: i)
                            break
                        }
                    }
                    self.songArrFiltered.remove(at: indexPath.row)
                }else{
                    if self.sortActive{
                        for i in 0..<songArrOffline.count{
                            if self.songArrSorted[indexPath.row].streamURL == songArrOffline[i].streamURL{
                                songArrOffline.remove(at: i)
                                break
                            }
                        }
                        self.songArrSorted.remove(at: indexPath.row)
                    }else{
                        songArrOffline.remove(at: indexPath.row)
                    }
                }
                tableView.reloadData()
            }
        })
        if let img1 = UIImage(named: "rowActionTrash") {
            deleteButton.backgroundColor = UIColor.imageWithBackgroundColor(img1, bgColor: UIColor.red)
        }
        //Button "Add to playlist"
        let addPlaylistButton = UITableViewRowAction(style: .default, title: "         ", handler: { (action, indexPath) in
            print("Add to Playlist")
        })
        if let img2 = UIImage(named: "rowActionAddPlaylist") {
            addPlaylistButton.backgroundColor = UIColor.imageWithBackgroundColor(img2, bgColor: UIColor(red:0.48, green:0.52, blue:0.99, alpha:1.0))
        }
        return [deleteButton, addPlaylistButton]
    }
}
