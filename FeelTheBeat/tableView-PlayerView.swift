//
//  tableView-PlayerView.swift
//  FeelTheBeat
//
//  Created by Dat on 7/30/16.
//  Copyright © 2016 trantuandat. All rights reserved.
//

import UIKit

extension PlayerViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songArr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        if indexPath.row == songSelected{
            cell.contentView.backgroundColor = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1.0)
            cell.backgroundColor = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1.0)
        }else{
            cell.contentView.backgroundColor = UIColor.clearColor()
            cell.backgroundColor = UIColor.clearColor()
        }
        cell.textLabel?.text = songArr[indexPath.row].title
        cell.detailTextLabel?.text = songArr[indexPath.row].artist
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        songSelected = indexPath.row
        player.pause()
        setSong(songSelected)
        player.play()
        reloadDisplay()
    }
}

