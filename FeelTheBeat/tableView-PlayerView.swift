//
//  tableView-PlayerView.swift
//  FeelTheBeat
//
//  Created by Dat on 7/30/16.
//  Copyright © 2016 trantuandat. All rights reserved.
//

import UIKit

extension PlayerViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if indexPath.row == songSelected{
            cell.contentView.backgroundColor = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1.0)
            cell.backgroundColor = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1.0)
        }else{
            cell.contentView.backgroundColor = UIColor.clear
            cell.backgroundColor = UIColor.clear
        }
        cell.textLabel?.text = songArr[indexPath.row].title
        cell.detailTextLabel?.text = songArr[indexPath.row].artist
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        songSelected = indexPath.row
        player.pause()
        setSong(songSelected)
        player.play()
        reloadDisplay()
    }
}

