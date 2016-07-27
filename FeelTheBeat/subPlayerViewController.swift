//
//  subPlayerViewController.swift
//  mp3ZingClone
//
//  Created by Dat on 6/28/16.
//  Copyright © 2016 trantuandat. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class subPlayerViewController: baseViewController{
    
    @IBOutlet weak var bg: UIButton!
    @IBOutlet weak var lblSongTitle: UILabel!
    @IBOutlet weak var lblSongArtist: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bg.setImage(UIImage(named: "purpleBackground"), forState: UIControlState.Normal)
    }
    override func viewWillAppear(animated: Bool) {
        if songArr.count > 0{
            if let _:AVPlayer = player{
                reloadData()
            }else{
                setSong(songSelected)
                reloadData()
                btnPlay.setImage(UIImage(named:"play"), forState: .Normal)
            }
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(subPlayerViewController.reloadSubPlayer(_:)), name: "reloadSubPlayer", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(PlayerViewController.self, name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
    }

    func playerDidFinishPlaying() {
        changeSong(true)
        reloadData()
    }
    func reloadSubPlayer(notification: NSNotification){
        reloadData()
    }

//-----------------------------Button action fuction--------------------------------------
    @IBAction func btnPlay(sender: AnyObject) {
        if let player:AVPlayer = player{
            if player.rate == 1.0 {
                player.pause()
                btnPlay.setImage(UIImage(named:"play"), forState: .Normal)
                MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [MPMediaItemPropertyArtist : songArr[songSelected].artist,  MPMediaItemPropertyTitle : songArr[songSelected].title, MPMediaItemPropertyPlaybackDuration : Float(CMTimeGetSeconds(playerItem.asset.duration)), MPNowPlayingInfoPropertyElapsedPlaybackTime : CMTimeGetSeconds(player.currentTime()), MPMediaItemPropertyRating : 0]
            }else{
                player.play()
                btnPlay.setImage(UIImage(named:"pause"), forState: .Normal)
                MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [MPMediaItemPropertyArtist : songArr[songSelected].artist,  MPMediaItemPropertyTitle : songArr[songSelected].title, MPMediaItemPropertyPlaybackDuration : Float(CMTimeGetSeconds(playerItem.asset.duration)), MPNowPlayingInfoPropertyElapsedPlaybackTime : CMTimeGetSeconds(player.currentTime()), MPMediaItemPropertyRating : 1]
            }
        }
    }
    @IBAction func btnNext(sender: AnyObject) {
        if let _:AVPlayer = player{
            changeSong(true)
            reloadData()
        }
    }
    @IBAction func btnPrev(sender: AnyObject) {
        if let _:AVPlayer = player{
            changeSong(false)
            reloadData()
        }
    }
    @IBAction func bg(sender: AnyObject) {
        if songArr.count > 0{
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("PlayerView") as! PlayerViewController
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    func reloadData(){
        if player.rate == 1.0 {
            btnPlay.setImage(UIImage(named:"pause"), forState: .Normal)
        }else{
            btnPlay.setImage(UIImage(named: "play"), forState: .Normal)
        }
        
        lblSongTitle.text = songArr[songSelected].title
        lblSongArtist.text = songArr[songSelected].artist
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(subPlayerViewController.playerDidFinishPlaying), name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
        
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [MPMediaItemPropertyArtist : songArr[songSelected].artist,  MPMediaItemPropertyTitle : songArr[songSelected].title, MPMediaItemPropertyPlaybackDuration : Float(CMTimeGetSeconds(playerItem.asset.duration)), MPNowPlayingInfoPropertyElapsedPlaybackTime : CMTimeGetSeconds(player.currentTime()), MPMediaItemPropertyRating : 1]
    }
}


