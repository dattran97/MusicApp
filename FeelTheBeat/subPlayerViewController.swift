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
        bg.setImage(UIImage(named: "purpleBackground"), for: UIControlState())
    }
    override func viewWillAppear(_ animated: Bool) {
        if songArr.count > 0{
            if let _:AVPlayer = player{
                reloadData()
            }else{
                setSong(songSelected)
                reloadData()
                btnPlay.setImage(UIImage(named:"play"), for: UIControlState())
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(subPlayerViewController.reloadSubPlayer(_:)), name: NSNotification.Name(rawValue: "reloadSubPlayer"), object: nil)
        NotificationCenter.default.removeObserver(PlayerViewController.self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }

    func playerDidFinishPlaying() {
        changeSong(true)
        reloadData()
    }
    func reloadSubPlayer(_ notification: Notification){
        reloadData()
    }

//-----------------------------Button action fuction--------------------------------------
    @IBAction func btnPlay(_ sender: AnyObject) {
        if let player:AVPlayer = player{
            if player.rate == 1.0 {
                player.pause()
                btnPlay.setImage(UIImage(named:"play"), for: UIControlState())
                MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyArtist : songArr[songSelected].artist,  MPMediaItemPropertyTitle : songArr[songSelected].title, MPMediaItemPropertyPlaybackDuration : Float(CMTimeGetSeconds(playerItem.asset.duration)), MPNowPlayingInfoPropertyElapsedPlaybackTime : CMTimeGetSeconds(player.currentTime()), MPMediaItemPropertyRating : 0]
            }else{
                player.play()
                btnPlay.setImage(UIImage(named:"pause"), for: UIControlState())
                MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyArtist : songArr[songSelected].artist,  MPMediaItemPropertyTitle : songArr[songSelected].title, MPMediaItemPropertyPlaybackDuration : Float(CMTimeGetSeconds(playerItem.asset.duration)), MPNowPlayingInfoPropertyElapsedPlaybackTime : CMTimeGetSeconds(player.currentTime()), MPMediaItemPropertyRating : 1]
            }
        }
    }
    @IBAction func btnNext(_ sender: AnyObject) {
        if let _:AVPlayer = player{
            changeSong(true)
            reloadData()
        }
    }
    @IBAction func btnPrev(_ sender: AnyObject) {
        if let _:AVPlayer = player{
            changeSong(false)
            reloadData()
        }
    }
    @IBAction func bg(_ sender: AnyObject) {
        if songArr.count > 0{
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "PlayerView") as! PlayerViewController
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func reloadData(){
        if player.rate == 1.0 {
            btnPlay.setImage(UIImage(named:"pause"), for: UIControlState())
        }else{
            btnPlay.setImage(UIImage(named: "play"), for: UIControlState())
        }
        
        lblSongTitle.text = songArr[songSelected].title
        lblSongArtist.text = songArr[songSelected].artist
        
        NotificationCenter.default.addObserver(self, selector: #selector(subPlayerViewController.playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyArtist : songArr[songSelected].artist,  MPMediaItemPropertyTitle : songArr[songSelected].title, MPMediaItemPropertyPlaybackDuration : Float(CMTimeGetSeconds(playerItem.asset.duration)), MPNowPlayingInfoPropertyElapsedPlaybackTime : CMTimeGetSeconds(player.currentTime()), MPMediaItemPropertyRating : 1]
    }
}


