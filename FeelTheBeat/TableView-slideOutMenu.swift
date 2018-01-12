//
//  TableView-sideOutMenu.swift
//  FeelTheBeat
//
//  Created by Dat on 7/20/16.
//  Copyright © 2016 trantuandat. All rights reserved.
//

import UIKit

extension slideOutMenuViewController:UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return menuArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArr[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = menuArr[indexPath.section][indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerArr[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var tmp:Int = 1
        for i in 0..<indexPath.section{
            tmp += menuArr[i].count
        }
        revealViewController().pushFrontViewController(desViewArr[indexPath.row + tmp - 1], animated: true)
    }
}
