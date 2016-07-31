//
//  CustomSearchBar-OnlineViewController.swift
//  FeelTheBeat
//
//  Created by Dat on 7/12/16.
//  Copyright © 2016 trantuandat. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

//-------------------------------Custom Search Bar---------------------------------------
private var requestTask:Request!

extension OnlineViewController:UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.becomeFirstResponder()
        showResults(searchText)
    }
    
    func showResults(searchText: String){
        if searchText != ""{
            let code:String = "54db3d4b-518f-4f50-aa34-393147a8aa18"
            songArrOnline = []
            requestTask?.cancel()
            //Show activityIndicatorView
            if loadingView.hidden == true{
                loadingView.hidden = false
            }
            let input = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            requestTask = Alamofire.request(.GET, "http://j.ginggong.com/jOut.ashx?k=\(input!)&h=\(source[sourceIndex])&code=\(code)")
            requestTask.responseJSON(completionHandler: { (responseData) in
                if responseData.result.value != nil{
                    let json = JSON(responseData.result.value!)
                    if let results:Array<Dictionary<String,AnyObject>> = json.arrayObject as? Array<Dictionary<String,AnyObject>>{
                        for i in results{
                            let song:Song = Song(dic: i)
                            if song.streamURL != ""{
                                songArrOnline.append(song)
                            }
                        }
                    }
                    self.loadingView.hidden = true
                    self.tableView.reloadData()
                    if songArrOnline.count != 0{
                        self.viewMess.hidden = true
                    }else{
                        self.lblMess.text = "Rất tiếc, chúng tôi không tìm thấy bài hát mà bạn yêu cầu!"
                        self.imgMess.image = UIImage(named: "sadFace")
                        self.viewMess.hidden = false
                    }
                }
            })
            
        }
        //Scroll to top after load a new result
        if tableView.numberOfRowsInSection(0) > 0{
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
        }
    }
}
