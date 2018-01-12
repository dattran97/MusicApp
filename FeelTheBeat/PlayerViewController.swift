//
//  ViewController.swift
//  mp3ZingClone
//
//  Created by Dat on 6/1/16.
//  Copyright © 2016 trantuandat. All rights reserved.
//

import UIKit
import AVFoundation
import Social
import MediaPlayer
import Kingfisher

class PlayerViewController: baseViewController, UIScrollViewDelegate{
    
    @IBOutlet weak var bg: UIImageView!
    @IBOutlet weak var viewLoading: UIView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnMode: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnPrev: UIButton!
    @IBOutlet weak var btnVolume: UIButton!
    @IBOutlet weak var sldVolume: UISlider!
    @IBOutlet weak var sldTime: UISlider!
    @IBOutlet weak var lblCurTime: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblSongTitle: UILabel!
    @IBOutlet weak var lblSongArtist: UILabel!
    @IBOutlet weak var txtLyrics: UITextView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var viewArtistAvatar: UIView!
    @IBOutlet weak var imgArtistAvatar: UIImageView!
    var secs:Int!
    var seconds:Int!
    var minutes:Int!
    var timer:Timer = Timer()
//-----------------------------------------View did load-------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDisplay()
        
        if let _:AVPlayer = player{
            //Check if player is playing
            let currentPlayerAsset = player.currentItem?.asset
            var url:String = (currentPlayerAsset as! AVURLAsset).url.absoluteString
            if !url.hasPrefix("http"){
                url = url.replacingOccurrences(of: ".mp3", with: "")
                if url.hasSuffix("/\(songArr[songSelected].streamURL)"){
                    url = songArr[songSelected].streamURL
                }
            }
            if url != songArr[songSelected].streamURL{
                player.pause()
                setSong(songSelected)
                player.play()
            }
        }else{
            setSong(songSelected)
            player.play()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.reloadMainPlayer(_:)), name: NSNotification.Name(rawValue: "reloadMainPlayer"), object: nil)
        NotificationCenter.default.removeObserver(subPlayerViewController.self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        reloadDisplay()
    }
    
    override func viewDidLayoutSubviews() {
        //UIImageView artist's avatar
        imgArtistAvatar.layer.cornerRadius = imgArtistAvatar.frame.size.height/2
        imgArtistAvatar.clipsToBounds = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    func reloadMainPlayer(_ notification: Notification){
        reloadDisplay()
    }
    
    @IBAction func dragNavigationBar(_ recognizer: UIPanGestureRecognizer) {
        let point = recognizer.location(in: self.view);
        if(recognizer.state == .ended){
            if point.y > self.view.frame.height/2{
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
//--------------------------------------Button action function--------------------------------------
    /**
    Hide sliderVolume after touch bg
    */
    @IBAction func bg(_ sender: AnyObject) {
        sldVolume.isHidden = true
    }
    
    @IBAction func barBtnShare(_ sender: AnyObject) {
        let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        vc?.setInitialText("Tôi đang nghe bài hát \(songArr[songSelected].title) với chất lượng cao trên app Lossless Music :\"> ")
        present(vc!, animated: true, completion: nil)
    }
    @IBAction func barBtnBackMenu(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnPlay(_ sender: AnyObject) {
        //If player is playing
        if player.rate == 1.0{
            pause()
        }else{
            play()
        }
    }
    @IBAction func btnMode(_ sender: AnyObject) {
        switch playerMode {
        case "shuffe":
            playerMode = "repeatAll"
            btnMode.setImage(UIImage(named: "repeatAll"), for: UIControlState())
        case "repeatAll":
            playerMode = "repeatOne"
            btnMode.setImage(UIImage(named: "repeatOne"), for: UIControlState())
        case "repeatOne":
            playerMode = "shuffe"
            btnMode.setImage(UIImage(named: "shuffe"), for: UIControlState())
            let indexArr = Array(0..<songArr.count)
            songArrShuffed = indexArr.shuffle()
        default:
            break
        }
    }
    @IBAction func btnPrev(_ sender: AnyObject) {
        changeSong(false)
        reloadDisplay()
    }
    @IBAction func btnNext(_ sender: AnyObject) {
        changeSong(true)
        reloadDisplay()
    }
    @IBAction func btnVolume(_ sender: AnyObject) {
        sldVolume.isHidden = (sldVolume.isHidden == false) ? true : false
    }
    @IBAction func sldVolume(_ sender: AnyObject) {
        player.volume = sldVolume.value
        volumeValue = sldVolume.value
        if sldVolume.value == sldVolume.minimumValue {
            btnVolume.setImage(UIImage(named: "volumeOff"), for: UIControlState())
        }else{
            btnVolume.setImage(UIImage(named: "volumeOn"), for: UIControlState())
        }
    }
    @IBAction func sldTime(_ sender: AnyObject) {
        timer.invalidate()
        
        player.seek(to: CMTimeMakeWithSeconds(Float64(sldTime.value), 60000), completionHandler: { (action) in
            if player.rate != 1.0{
                self.btnPlay.setImage(UIImage(named:"pause"), for: UIControlState())
                player.play()
                self.imgArtistAvatar.layer.removeAllAnimations()
                self.rotateSpinningView()
            }
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyArtist : songArr[songSelected].artist,  MPMediaItemPropertyTitle : songArr[songSelected].title, MPMediaItemPropertyPlaybackDuration : Float(CMTimeGetSeconds(playerItem.asset.duration)), MPNowPlayingInfoPropertyElapsedPlaybackTime : CMTimeGetSeconds(player.currentTime()), MPMediaItemPropertyRating : 1]
        }) 
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(PlayerViewController.updateSlider), userInfo: nil, repeats: true)
    }
    
    func updateSlider(){
        sldTime.value += 0.1
        secs = lround(CMTimeGetSeconds(playerItem.currentTime()))
        minutes = (Int)(secs/60)
        seconds = (Int)(secs%60)
        lblCurTime.text = (String)(minutes) + ":" +  ((seconds < 10) ? "0" : "") + (String)(seconds)
    }

//--------------------------------------Support function--------------------------------------
    func play(){
        imgArtistAvatar.layer.removeAllAnimations()
        rotateSpinningView()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(PlayerViewController.updateSlider), userInfo: nil, repeats: true)
        btnPlay.setImage(UIImage(named:"pause"), for: UIControlState())
        player.play()
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyArtist : songArr[songSelected].artist,  MPMediaItemPropertyTitle : songArr[songSelected].title, MPMediaItemPropertyPlaybackDuration : Float(CMTimeGetSeconds(playerItem.asset.duration)), MPNowPlayingInfoPropertyElapsedPlaybackTime : CMTimeGetSeconds(player.currentTime()), MPMediaItemPropertyRating : 1]
    }
    
    func pause(){
        imgArtistAvatar.layer.removeAllAnimations()
        timer.invalidate()
        btnPlay.setImage(UIImage(named:"play"), for: UIControlState())
        player.pause()
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyArtist : songArr[songSelected].artist,  MPMediaItemPropertyTitle : songArr[songSelected].title, MPMediaItemPropertyPlaybackDuration : Float(CMTimeGetSeconds(playerItem.asset.duration)), MPNowPlayingInfoPropertyElapsedPlaybackTime : CMTimeGetSeconds(player.currentTime()), MPMediaItemPropertyRating : 0]
    }
    
    func reloadDisplay(){
        //Refresh objects in Scroll View
        tableView.reloadData()
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        imgArtistAvatar.kf.setImage(with: URL(string: songArr[songSelected].avatarURL))
        
        //Lyrics Textview
        if songArr[songSelected].lyricsURL != ""{
            if songArr[songSelected].lyricsURL.hasPrefix("http"){
                let url = URL(string: songArr[songSelected].lyricsURL)
                do{
                    let lyrics = try String(contentsOf: url!)
                    let decodedString = String(htmlEncodedString: lyrics)
                    txtLyrics.text = decodedString
                }catch{
                    txtLyrics.text = "Chưa có lời bài hát cho bản nhạc này"
                }
            }else{
                txtLyrics.text = songArr[songSelected].lyricsURL
            }
        }else{
            txtLyrics.text = "Chưa có lời bài hát cho bản nhạc này"
        }
        txtLyrics.scrollRangeToVisible(NSMakeRange(0, 0))
        
        //Slidertime & SliderVolume
        sldTime.maximumValue = Float(CMTimeGetSeconds(playerItem.asset.duration))
        sldTime.value = Float(CMTimeGetSeconds(playerItem.currentTime()))
        if sldVolume.value == sldVolume.minimumValue {
            btnVolume.setImage(UIImage(named: "volumeOff"), for: UIControlState())
        }

        
        //Title Label & Artist Label
        lblSongTitle.text = songArr[songSelected].title
        lblSongArtist.text = songArr[songSelected].artist
        
        //Mode Button
        switch playerMode {
        case "repeatAll":
            btnMode.setImage(UIImage(named: "repeatAll"), for: UIControlState())
        case "repeatOne":
            btnMode.setImage(UIImage(named: "repeatOne"), for: UIControlState())
        case "shuffe":
            btnMode.setImage(UIImage(named: "shuffe"), for: UIControlState())
            let indexArr = Array(0..<songArr.count)
            songArrShuffed = indexArr.shuffle()
        default:
            btnMode.setImage(UIImage(named: "repeatAll"), for: UIControlState())
        }
        
        //Timer & play/pause Button
        if player.rate == 1.0 {
            timer.invalidate()
            player.pause()
            play()
        }else{
            btnPlay.setImage(UIImage(named:"play"), for: UIControlState())
        }
        
        //Duration Label
        secs = lround(CMTimeGetSeconds(playerItem.asset.duration))
        minutes = (Int)(secs/60)
        seconds = (Int)(secs%60)
        lblDuration.text = (String)(minutes) + ":" +  ((seconds < 10) ? "0" : "") + (String)(seconds)
        //Current time Label
        secs = lround(CMTimeGetSeconds(playerItem.currentTime()))
        minutes = (Int)(secs/60)
        seconds = (Int)(secs%60)
        lblCurTime.text = (String)(minutes) + ":" +  ((seconds < 10) ? "0" : "") + (String)(seconds)

        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        //MPNowPlayingInfoCenter
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyArtist : songArr[songSelected].artist,  MPMediaItemPropertyTitle : songArr[songSelected].title, MPMediaItemPropertyPlaybackDuration : Float(CMTimeGetSeconds(playerItem.asset.duration)), MPNowPlayingInfoPropertyElapsedPlaybackTime : CMTimeGetSeconds(player.currentTime()), MPMediaItemPropertyRating : 1]
    }

    func initDisplay(){
        sldTime.setThumbImage(UIImage(named: "thumbTint"), for: UIControlState())
        sldVolume.setThumbImage(UIImage(named: "thumbTint"), for: UIControlState())
        sldVolume.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
        sldVolume.minimumValue = 0
        sldVolume.maximumValue = 1
        
        sldTime.minimumValue = 0
        //Add Gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(PlayerViewController.dragNavigationBar))
        self.navigationBar.addGestureRecognizer(panGesture)
        
        //Page Controll
        scrollView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        self.pageControl.numberOfPages = 3
        self.pageControl.currentPage = 0
        self.pageControl.pageIndicatorTintColor = UIColor.gray
        self.pageControl.currentPageIndicatorTintColor = UIColor(red:0.48, green:0.52, blue:0.99, alpha:1.0)
        pageControl.addTarget(self, action: #selector(PlayerViewController.changePage(_:)), for: UIControlEvents.valueChanged)
    }
    
    //Change page when click on pagecontrol
    func changePage(_ sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        if pageNumber == 2 {
            if player.rate == 1.0{
                imgArtistAvatar.layer.removeAllAnimations()
                rotateSpinningView()
            }
            bg.image = UIImage(named: "playerBackground2")
        }else{
            bg.image = UIImage(named: "playerBackground")
        }
    }
 
    //Rotate artist image
    func rotateSpinningView() {
        UIView.animate(withDuration: 2, delay: 0, options: .curveLinear, animations: {() -> Void in
            self.imgArtistAvatar.transform = self.imgArtistAvatar.transform.rotated(by: CGFloat.pi/2)
            }, completion: {(finished: Bool) -> Void in
                if finished && self.imgArtistAvatar.transform != CGAffineTransform.identity {
                    self.rotateSpinningView()
                }
            }
        )
    }
    
    //Change song after finish playing
    func playerDidFinishPlaying(){
        changeSong(true)
        reloadDisplay()
    }
}

