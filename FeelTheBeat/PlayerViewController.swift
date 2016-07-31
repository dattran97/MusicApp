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
    var timer:NSTimer = NSTimer()
//-----------------------------------------View did load-------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDisplay()
        
        if let _:AVPlayer = player{
            //Check if player is playing
            let currentPlayerAsset = player.currentItem?.asset
            var url:String = (currentPlayerAsset as! AVURLAsset).URL.absoluteString
            if !url.hasPrefix("http"){
                url = url.stringByReplacingOccurrencesOfString(".mp3", withString: "")
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlayerViewController.reloadMainPlayer(_:)), name: "reloadMainPlayer", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(subPlayerViewController.self, name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
        reloadDisplay()
    }
    
    override func viewDidLayoutSubviews() {
        //UIImageView artist's avatar
        imgArtistAvatar.layer.cornerRadius = imgArtistAvatar.frame.size.height/2
        imgArtistAvatar.clipsToBounds = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        timer.invalidate()
    }
    
    func reloadMainPlayer(notification: NSNotification){
        reloadDisplay()
    }
    
    @IBAction func dragNavigationBar(recognizer: UIPanGestureRecognizer) {
        let point = recognizer.locationInView(self.view);
        if(recognizer.state == .Ended){
            if point.y > self.view.frame.height/2{
                dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
//--------------------------------------Button action function--------------------------------------
    /**
    Hide sliderVolume after touch bg
    */
    @IBAction func bg(sender: AnyObject) {
        sldVolume.hidden = true
    }
    
    @IBAction func barBtnShare(sender: AnyObject) {
        let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        vc.setInitialText("Tôi đang nghe bài hát \(songArr[songSelected].title) với chất lượng cao trên app Lossless Music :\"> ")
        presentViewController(vc, animated: true, completion: nil)
    }
    @IBAction func barBtnBackMenu(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnPlay(sender: AnyObject) {
        //If player is playing
        if player.rate == 1.0{
            pause()
        }else{
            play()
        }
    }
    @IBAction func btnMode(sender: AnyObject) {
        switch playerMode {
        case "shuffe":
            playerMode = "repeatAll"
            btnMode.setImage(UIImage(named: "repeatAll"), forState: .Normal)
        case "repeatAll":
            playerMode = "repeatOne"
            btnMode.setImage(UIImage(named: "repeatOne"), forState: .Normal)
        case "repeatOne":
            playerMode = "shuffe"
            btnMode.setImage(UIImage(named: "shuffe"), forState: .Normal)
            let indexArr = Array(0..<songArr.count)
            songArrShuffed = indexArr.shuffle()
        default:
            break
        }
    }
    @IBAction func btnPrev(sender: AnyObject) {
        changeSong(false)
        reloadDisplay()
    }
    @IBAction func btnNext(sender: AnyObject) {
        changeSong(true)
        reloadDisplay()
    }
    @IBAction func btnVolume(sender: AnyObject) {
        sldVolume.hidden = (sldVolume.hidden == false) ? true : false
    }
    @IBAction func sldVolume(sender: AnyObject) {
        player.volume = sldVolume.value
        volumeValue = sldVolume.value
        if sldVolume.value == sldVolume.minimumValue {
            btnVolume.setImage(UIImage(named: "volumeOff"), forState: UIControlState.Normal)
        }else{
            btnVolume.setImage(UIImage(named: "volumeOn"), forState: UIControlState.Normal)
        }
    }
    @IBAction func sldTime(sender: AnyObject) {
        timer.invalidate()
        
        player.seekToTime(CMTimeMakeWithSeconds(Float64(sldTime.value), 60000)) { (action) in
            if player.rate != 1.0{
                self.btnPlay.setImage(UIImage(named:"pause"), forState: .Normal)
                player.play()
                self.imgArtistAvatar.layer.removeAllAnimations()
                self.rotateSpinningView()
            }
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [MPMediaItemPropertyArtist : songArr[songSelected].artist,  MPMediaItemPropertyTitle : songArr[songSelected].title, MPMediaItemPropertyPlaybackDuration : Float(CMTimeGetSeconds(playerItem.asset.duration)), MPNowPlayingInfoPropertyElapsedPlaybackTime : CMTimeGetSeconds(player.currentTime()), MPMediaItemPropertyRating : 1]
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(PlayerViewController.updateSlider), userInfo: nil, repeats: true)
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
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(PlayerViewController.updateSlider), userInfo: nil, repeats: true)
        btnPlay.setImage(UIImage(named:"pause"), forState: .Normal)
        player.play()
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [MPMediaItemPropertyArtist : songArr[songSelected].artist,  MPMediaItemPropertyTitle : songArr[songSelected].title, MPMediaItemPropertyPlaybackDuration : Float(CMTimeGetSeconds(playerItem.asset.duration)), MPNowPlayingInfoPropertyElapsedPlaybackTime : CMTimeGetSeconds(player.currentTime()), MPMediaItemPropertyRating : 1]
    }
    
    func pause(){
        imgArtistAvatar.layer.removeAllAnimations()
        timer.invalidate()
        btnPlay.setImage(UIImage(named:"play"), forState: .Normal)
        player.pause()
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [MPMediaItemPropertyArtist : songArr[songSelected].artist,  MPMediaItemPropertyTitle : songArr[songSelected].title, MPMediaItemPropertyPlaybackDuration : Float(CMTimeGetSeconds(playerItem.asset.duration)), MPNowPlayingInfoPropertyElapsedPlaybackTime : CMTimeGetSeconds(player.currentTime()), MPMediaItemPropertyRating : 0]
    }
    
    func reloadDisplay(){
        //Refresh objects in Scroll View
        tableView.reloadData()
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        imgArtistAvatar.loadImageFromUsingCache(songArr[songSelected].avatarURL)
        
        //Lyrics Textview
        if songArr[songSelected].lyricsURL != ""{
            if songArr[songSelected].lyricsURL.hasPrefix("http"){
                let url = NSURL(string: songArr[songSelected].lyricsURL)
                do{
                    let lyrics = try String(contentsOfURL: url!)
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
            btnVolume.setImage(UIImage(named: "volumeOff"), forState: UIControlState.Normal)
        }

        
        //Title Label & Artist Label
        lblSongTitle.text = songArr[songSelected].title
        lblSongArtist.text = songArr[songSelected].artist
        
        //Mode Button
        switch playerMode {
        case "repeatAll":
            btnMode.setImage(UIImage(named: "repeatAll"), forState: .Normal)
        case "repeatOne":
            btnMode.setImage(UIImage(named: "repeatOne"), forState: .Normal)
        case "shuffe":
            btnMode.setImage(UIImage(named: "shuffe"), forState: .Normal)
            let indexArr = Array(0..<songArr.count)
            songArrShuffed = indexArr.shuffle()
        default:
            btnMode.setImage(UIImage(named: "repeatAll"), forState: .Normal)
        }
        
        //Timer & play/pause Button
        if player.rate == 1.0 {
            timer.invalidate()
            player.pause()
            play()
        }else{
            btnPlay.setImage(UIImage(named:"play"), forState: .Normal)
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

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerDidFinishPlaying), name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
        //MPNowPlayingInfoCenter
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [MPMediaItemPropertyArtist : songArr[songSelected].artist,  MPMediaItemPropertyTitle : songArr[songSelected].title, MPMediaItemPropertyPlaybackDuration : Float(CMTimeGetSeconds(playerItem.asset.duration)), MPNowPlayingInfoPropertyElapsedPlaybackTime : CMTimeGetSeconds(player.currentTime()), MPMediaItemPropertyRating : 1]
    }

    func initDisplay(){
        sldTime.setThumbImage(UIImage(named: "thumbTint"), forState: .Normal)
        sldVolume.setThumbImage(UIImage(named: "thumbTint"), forState: .Normal)
        sldVolume.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
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
        self.pageControl.pageIndicatorTintColor = UIColor.grayColor()
        self.pageControl.currentPageIndicatorTintColor = UIColor(red:0.48, green:0.52, blue:0.99, alpha:1.0)
        pageControl.addTarget(self, action: #selector(PlayerViewController.changePage(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    //Change page when click on pagecontrol
    func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPointMake(x, 0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
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
        UIView.animateWithDuration(2, delay: 0, options: .CurveLinear, animations: {() -> Void in
            self.imgArtistAvatar.transform = CGAffineTransformRotate(self.imgArtistAvatar.transform, CGFloat(M_PI_2))
            }, completion: {(finished: Bool) -> Void in
                if finished && !CGAffineTransformEqualToTransform(self.imgArtistAvatar.transform, CGAffineTransformIdentity) {
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

