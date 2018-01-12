//
//  CustomSearchBar-OfflineViewController.swift
//  FeelTheBeat
//
//  Created by Dat on 7/13/16.
//  Copyright © 2016 trantuandat. All rights reserved.
//

import UIKit

//-------------------------------Custom Search Bar---------------------------------------
extension OfflineViewController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if songArrFiltered.count == 0{
            searchBarActive = false
        }
        view.endEditing(true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBarActive = true
        searchBar.becomeFirstResponder()
        songArrFiltered = songArrOffline.filter({ (song:Song) -> Bool in
            return song.title.range(of: searchText, options: NSString.CompareOptions.caseInsensitive) != nil
        })
        if searchText == "" || searchBarActive == false{
            searchBarActive = false
        }
        tableView.reloadData()
        //Scroll to top after load a new result
        if tableView.numberOfRows(inSection: 0) > 0{
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
}
