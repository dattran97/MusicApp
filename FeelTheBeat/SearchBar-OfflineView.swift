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
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if songArrFiltered.count == 0{
            searchBarActive = false
        }
        view.endEditing(true)
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchBarActive = true
        searchBar.becomeFirstResponder()
        songArrFiltered = songArrOffline.filter({ (song:Song) -> Bool in
            return song.title.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil
        })
        if searchText == "" || searchBarActive == false{
            searchBarActive = false
        }
        tableView.reloadData()
        //Scroll to top after load a new result
        if tableView.numberOfRowsInSection(0) > 0{
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
        }
    }
}