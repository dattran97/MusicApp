//
//  TableView-sideOutMenu.swift
//  FeelTheBeat
//
//  Created by Dat on 7/20/16.
//  Copyright © 2016 trantuandat. All rights reserved.
//

import UIKit

extension slideOutMenuViewController:UITableViewDelegate, UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return menuArr.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArr[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = menuArr[indexPath.section][indexPath.row]
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.clearColor()
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerArr[section]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var tmp:Int = 1
        for i in 0..<indexPath.section{
            tmp += menuArr[i].count
        }
        revealViewController().pushFrontViewController(desViewArr[indexPath.row + tmp - 1], animated: true)
    }
}
