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
private var requestTask:DataRequest?

extension OnlineViewController:UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.becomeFirstResponder()
        showResults(searchText)
    }
    
    func showResults(_ searchText: String){
        if searchText != ""{
            let code:String = "54db3d4b-518f-4f50-aa34-393147a8aa18"
            songArrOnline = []
            requestTask?.cancel()
            //Show activityIndicatorView
            if loadingView.isHidden == true{
                loadingView.isHidden = false
            }
            let input = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            requestTask = Alamofire.request("http://j.ginggong.com/jOut.ashx?k=\(input!)&code=\(code)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            requestTask?.responseJSON { (response:DataResponse<Any>) in
                if response.result.value != nil{
                    let json = JSON(response.result.value!)
                    if let results:Array<Dictionary<String,AnyObject>> = json.arrayObject as? Array<Dictionary<String,AnyObject>>{
                        for i in results{
                            let song:Song = Song(dic: i)
                            if song.streamURL != ""{
                                songArrOnline.append(song)
                            }
                        }
                    }
                    self.loadingView.isHidden = true
                    self.tableView.reloadData()
                    if songArrOnline.count != 0{
                        self.viewMess.isHidden = true
                    }else{
                        self.lblMess.text = "Rất tiếc, chúng tôi không tìm thấy bài hát mà bạn yêu cầu!"
                        self.imgMess.image = UIImage(named: "sadFace")
                        self.viewMess.isHidden = false
                    }
                }
            }
            
        }
        //Scroll to top after load a new result
        if tableView.numberOfRows(inSection: 0) > 0{
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
}
